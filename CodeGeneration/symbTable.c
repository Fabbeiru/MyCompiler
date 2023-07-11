#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include "symbTable.h"
#include <errno.h>

char *initCategories = "VF";
struct Node *head = NULL;

struct Node *searchName(char *varName) {
    struct Node *aux = head;
	while (aux!=NULL && strcmp(aux->varName, varName)!=0) {
        aux = aux->next;
    }
	return aux;
}

struct Node *searchCat(char *varName, enum categories cat) {
    struct Node *aux = searchName(varName);
	if (aux!=NULL && aux->cat==cat) {
        return aux;
    } else {
        return NULL;
    }
}

struct Node *insert(char *varName, enum categories cat) {
    if (searchName(varName) != NULL) perror("name already defined");
    struct Node *aux = (struct Node *)malloc(sizeof(struct Node));
    aux->varName = varName;
    aux->cat = cat;
    aux->next = head;
    aux->functArguments = 0;
    head = aux;
    return aux;
}

struct Node *addAddress(char *varName, enum categories cat, int address) {
	struct Node *aux = insert(varName, cat);
	aux->address=address;
	return aux;
}

void freeMemory() {
    while(head!=NULL && head->cat!=func){
        struct Node *aux = head->next;
        free(head->varName);
        free(head);
        head = aux;
	}
}

void showInConsole(const char* s) {
    printf(" Block: %s\n", s);
	struct Node *aux = head;
	while(aux != NULL){
		printf(" 0x%lx %c %s\n", (long)aux, initCategories[aux->cat], aux->varName);
		aux = aux->next;
	}
}
