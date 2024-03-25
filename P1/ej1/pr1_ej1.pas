program pr1_ej1;
const
    corte = 30000;
type
    archInt = file of Integer;
var
    archivo: archInt;
    nombreArch: String[20];
    num: Integer;
begin
    WriteLn('Ingrese nombre del archivo: ');
    ReadLn(nombreArch);

    Assign(archivo, nombreArch);
    Rewrite(archivo);

    WriteLn('Ingrese un numero: ');
    ReadLn(num);
    while(num <> corte) do begin
        Write(archivo, num);

        WriteLn('Ingrese un numero: ');
        ReadLn(num);
    end;

    close(archivo);
end.