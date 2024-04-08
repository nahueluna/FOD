program pr2_ej11;
const
    valorAlto = 9999;
type
    rangoMes = 1..12;
    rangoDia = 1..31;

    acceso = record
        anio: Integer;
        mes: rangoMes;
        dia: rangoDia;
        id_usuario: Integer;
        tiempo: Integer;
    end;

    archivo_accesos = file of acceso;

procedure asignar(var maestro: archivo_accesos);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure leer(var maestro: archivo_accesos; var regM: acceso);
begin
    if(not Eof(maestro)) then Read(maestro, regM)
    else regM.anio := valorAlto;
end;

procedure reporteAccesos(var maestro: archivo_accesos);
var
    regM: acceso;
    anioLeido, accesosAnio, accesosMes, accesosDia: Integer;
    mesActual: rangoMes;
    diaActual: rangoDia;
begin
    Reset(maestro);

    Write('Ingrese el anio para generar el reporte: '); ReadLn(anioLeido);

    leer(maestro, regM);
    while(regM.anio <> valorAlto) and (regM.anio < anioLeido) do
        leer(maestro, regM);
    
    if(regM.anio = anioLeido) then begin
        accesosAnio := 0;
        WriteLn('ANIO: ', anioLeido);
        WriteLn;
        
        while(regM.anio = anioLeido) do begin
            mesActual := regM.mes;
            accesosMes := 0;

            WriteLn(#9'Mes: ', mesActual);

            while(regM.anio = anioLeido) and (regM.mes = mesActual) do begin
                diaActual := regM.dia;
                accesosDia := 0;

                WriteLn(#9#9'Dia: ', diaActual);

                while(regM.anio = anioLeido) and (regM.mes = mesActual) and (regM.dia = diaActual) do begin
                    accesosDia := accesosDia + regM.tiempo;

                    WriteLn(#9#9#9'Usuario: ', regM.id_usuario, #9'Timpo de acceso: ', regM.tiempo);

                    leer(maestro, regM);
                end;
                accesosMes := accesosMes + accesosDia;

                WriteLn(#9#9'Tiempo total de acceso en el dia: ', accesosDia); 
            end;

            accesosAnio := accesosAnio + accesosMes;

            WriteLn(#9'Tiempo total de acceso en el mes: ', accesosMes);
            WriteLn;
        end;

        WriteLn('Tiempo total de acceso en el anio: ', accesosAnio);
    end
    else WriteLn('Anio no encontrado');

    Close(maestro);
end;

var
    archivo_maestro: archivo_accesos;
begin
    asignar(archivo_maestro);

    WriteLn;

    reporteAccesos(archivo_maestro);
end.