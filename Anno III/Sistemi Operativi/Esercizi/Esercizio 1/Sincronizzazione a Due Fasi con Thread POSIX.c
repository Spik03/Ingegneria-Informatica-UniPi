#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>

#define N 5
#define S 10

pthread_cond_t barrier;
pthread_cond_t last;
pthread_mutex_t M;

int pos;
int check;
bool fine;

void* tr_code(void* arg){
	int* buffer = (int*)arg;
	for(int i=0;i<2;++i){	// gestisco le due fase tramite un for
		int num = rand()%100+1;
		pthread_mutex_lock(&M);
		pos = (pos+1)%S;
		buffer[pos]=num;
		if(!i){	// nella fase 2 (i=1) non devo fare queste operazioni
			++check;
			if(check==N)
				pthread_cond_signal(&last);
			while(!fine)
				pthread_cond_wait(&barrier, &M);
		}
		pthread_mutex_unlock(&M);
	}
	pthread_exit(NULL);
}

void stampa(const char* msg, int* buffer){
	printf("%s", msg); 
	for(int i=0; i<S;++i)
		printf(" %d",buffer[i]);
	printf("\n");
}

int main(){
	srand(time(NULL));

	pthread_t tr[N];
	int buffer[S];

	pos=-1;
	check=0;
	fine = false;

	for(int i=0;i<S;++i) 
		buffer[i]=-1; // non importa mutua esclusione in questo punto

	pthread_cond_init(&barrier, NULL);
	pthread_cond_init(&last, NULL);
	pthread_mutex_init(&M, NULL);

	for(int i=0;i<N;++i){
		int ret = pthread_create(&tr[i], NULL, tr_code, buffer);
		if(ret)
			exit(-1); 
	}

	pthread_mutex_lock(&M);

	while(check<N) 
		pthread_cond_wait(&last, &M);

	stampa("1) Stato Attuale:",buffer);
	fine = true;
	pthread_cond_broadcast(&barrier);

	pthread_mutex_unlock(&M);

	for (int i = 0; i < N; ++i)
        	pthread_join(tr[i], NULL);

	stampa("2) Stato Finale:",buffer);
	
	pthread_mutex_destroy(&M);
	pthread_cond_destroy(&barrier);
	pthread_cond_destroy(&last);
	pthread_exit(NULL);
}
