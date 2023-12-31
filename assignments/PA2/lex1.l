%{
#include<stdio.h>
int nline, ncolumn, nnword, column;
%}

%%

[ \t] {column++;}
[^ \t\n]+ {
    nnword++;
    column+=yyleng;
}
\n {
    ncolumn=(ncolumn>column)?ncolumn:column;
    ++nline;
    column=0;
}

%%

int main(){
    printf("Press CTRL+d to quit.\nInput any text:\n");
    yylex();             /* 调用词法分析器，直到输入结束  */
    printf("nline=%d, ncolumn=%d, nnword=%d\n", nline, ncolumn, nnword);
    return 0;
}