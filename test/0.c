// int a = 1
// int b = 2;
// if(!2==3){
//     int a=2;
//     a=a+2;
// }
// while(a==b){
//     printf("%d", a);
// }
void main()
{
    int a, b, c = 10;
    scanf("%d", &b);
    printf("%d\n", a);
    while(a < c)
    {
        a++;
        printf("WHILE%d\n", a);
    }
    printf("MOD%d\n", b % c);
    for (int i = 0; i < b;i++)
    {
        printf("FOR%d\n", a + c * i);
    }
}