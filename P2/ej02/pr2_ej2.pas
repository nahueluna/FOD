program pr2_ej2;
const
    valorAlto = '9999';
type
    alumno = record
        codigo: String[10];
        apellido: String[20];
        nombre: String[20];
        materias_sin_final: Integer;
        materias_con_final: Integer;
    end;

    info_alumno = record
        codigo: String[10];
        cursada_aprobada: Boolean;
        final_aprobado: Boolean;
    end;

    archivo_alumnos = file of alumno;
    detalle_alumnos = file of info_alumno;

procedure asignarDetalle(var archivo: detalle_alumnos);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo: ');
    ReadLn(path);
    Assign(archivo, path);
end;

procedure asignarMaestro(var archivo: archivo_alumnos);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo: ');
    ReadLn(path);
    Assign(archivo, path);
end;

procedure leer(var detalle: detalle_alumnos; var regDetalle: info_alumno);
begin
    if(not Eof(detalle)) then Read(detalle, regDetalle)
    else regDetalle.codigo := valorAlto;
end;

procedure actualizarMaestro(var maestro: archivo_alumnos; var detalle: detalle_alumnos);
var
    regM: alumno;
    regD: info_alumno;
    codigoActual: String[10]; 
    cantFinal, cantCursada: Integer;
begin
    Reset(maestro);
    Reset(detalle);

    leer(detalle, regD);
    Read(maestro, regM);

    while(regD.codigo <> valorAlto) do begin
        codigoActual := regD.codigo;
        cantFinal := 0;
        cantCursada := 0;

        //Busco en detalle y acumulo cantidad aprobados
        while(codigoActual = regD.codigo) do begin
            
            with regD do begin
                if(final_aprobado) then begin
                    cantFinal:= cantFinal + 1;
                    cantCursada:= cantCursada - 1;
                end
                else if(cursada_aprobada) then
                    cantCursada := cantCursada + 1
            end;

            leer(detalle, regD);
        end;

        //Busco el correspondiente registro en el maestro
        while(codigoActual <> regM.codigo) do
            Read(maestro, regM);

        //Actualizo para escribir en maestro
        regM.materias_sin_final := regM.materias_sin_final + cantCursada;
        regM.materias_con_final := regM.materias_con_final + cantFinal;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);
    end;

    Close(detalle);
    Close(maestro);
end;

procedure generarArchivoTexto(var maestro: archivo_alumnos);
var
    alumnos_texto: Text;
    regAlu: alumno;
begin
    Assign(alumnos_texto, 'alumnos_mayor_finales.txt');
    
    Reset(maestro);
    Rewrite(alumnos_texto);

    while(not Eof(maestro)) do begin
        Read(maestro, regAlu);
        
        with(regAlu) do begin
            if(materias_con_final > materias_sin_final) then
                WriteLn(alumnos_texto, codigo, ' ', apellido, ' ', nombre, ' ', materias_sin_final, ' ', materias_con_final);
        end;

    end;

    Close(alumnos_texto);
    Close(maestro);
end;

procedure callMenu(var maestro: archivo_alumnos; var detalle: detalle_alumnos);
var
    opcion: Integer;
begin
    WriteLn('Menu archivos de alumno-materias');
    WriteLn('Elija una opcion: ');
    WriteLn('1- Actualizar archivo maestro');
    WriteLn('2- Exportar a texto alumnos con mas finales aprobados que materias sin final');
    WriteLn('3- Salir');

    Write('=> ');
    ReadLn(opcion);

    while(opcion <> 3) do begin

        case opcion of
            
            1: actualizarMaestro(maestro, detalle);

            2: generarArchivoTexto(maestro);

            else
                WriteLn('La opcion ingresada no es valida');
        end;

        WriteLn;
        Write('=> ');
        ReadLn(opcion);
    end;
    
end;

var
    archivo_maestro: archivo_alumnos;
    archivo_detalle: detalle_alumnos;
begin
    asignarDetalle(archivo_detalle);
    asignarMaestro(archivo_maestro);

    callMenu(archivo_maestro, archivo_detalle);
end.