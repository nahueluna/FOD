program pr1_ej2;
type
    archInt = file of Integer;

procedure asignar(var archivo:archInt);
var
    ruta: String;
begin
    WriteLn('Ingrese nombre del archivo: ');    ///home/nahuel/Documentos/InfoUNLP/3erSemestre/FOD/P1/ej1/numeros_enteros
    ReadLn(ruta);
    Assign(archivo, ruta);
end;

procedure procesar(var archivo: archInt; var cantNum: Integer; var promedio: Real);
var
    num:Integer;
begin
    cantNum:=0;
    promedio:=0;
    
    while(not Eof(archivo)) do begin
        Read(archivo, num);
        if(num < 1500) then cantNum:= cantNum + 1;
        promedio:= promedio + num;

        WriteLn(num);
    end;

    promedio:= promedio/FileSize(archivo);
end;


var
    archivo: archInt;
    cantNum: Integer;
    promedio: Real;
begin
    asignar(archivo);
    Reset(archivo);
    procesar(archivo, cantNum, promedio);

    WriteLn('Cantidad de numeros menores a 1500: ',cantNum);
    WriteLn('Promedio de numeros ingresados: ',promedio:1:2);
end.