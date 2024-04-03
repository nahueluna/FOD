program pr2_ej1;
const
    valorAlto = '9999';
type
    empleado = record
        codigo: String[10];
        nombre: String[20];
        comision: Real;
    end;

    archivo_comisiones = file of empleado;

procedure asignar(var archivo: archivo_comisiones);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo: ');
    ReadLn(path);
    Assign(archivo, path);
end;

procedure leer(var archivo: archivo_comisiones; var regEmpl: empleado);
begin
    if(not EOF(archivo)) then Read(archivo, regEmpl)
    else regEmpl.codigo := valorAlto;
end;

procedure procesarArchivoDetalle(var detalle: archivo_comisiones; var maestro: archivo_comisiones);
var
    regD, regAux: empleado;
    totalComision: Real;
begin
    Reset(detalle);
    Rewrite(maestro);

    leer(detalle, regD);

    while(regD.codigo <> valorAlto) do begin
        regAux := regD;
        totalComision := 0;

        while(regAux.codigo = regD.codigo) do begin
            totalComision := totalComision + regD.comision;
            leer(detalle, regD);
        end;

        regAux.comision := totalComision;
        Write(maestro, regAux);
    end;

    Close(maestro);
    Close(detalle);
end;

var
    archivo_detalle: archivo_comisiones;
    archivo_maestro: archivo_comisiones;
begin
    asignar(archivo_detalle);
    asignar(archivo_maestro);

    procesarArchivoDetalle(archivo_detalle, archivo_maestro);
end.