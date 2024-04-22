program pr3_ej2;
const
    numeroLimite = 1000;
    caracter = '*';
type
    asistente = record
        numero: Integer;
        apellido: String[20];
        nombre: String[20];
        email: String[40];
        telefono: LongInt;
        dni: LongInt;
    end;

    archivo_asistentes = file of asistente;

procedure crearArchivo(var archivo: archivo_asistentes);
    procedure leerAsistente(var reg: asistente);
    begin
        with reg do begin
            Write('Numero: '); ReadLn(numero);
            if(numero <> 0) then begin
                Write('Apellido: '); Readln(apellido);
                Write('Nombre: '); ReadLn(nombre);
                Write('Email: '); ReadLn(email);
                Write('Telefono: '); ReadLn(telefono);
                Write('DNI: '); ReadLn(dni);
            end;
            WriteLn;
        end;
    end;
var
    reg_asis: asistente;
begin
    Rewrite(archivo);

    leerAsistente(reg_asis);
    while(reg_asis.numero <> 0) do begin
        Write(archivo, reg_asis);
        leerAsistente(reg_asis);
    end;

    WriteLn('Creacion finalizada.');
    WriteLn;

    Close(archivo);
end;

procedure bajaLogicaArchivo(var archivo: archivo_asistentes);
var
    reg_asis: asistente;
begin
    Reset(archivo);

    while(not Eof(archivo)) do begin
        Read(archivo, reg_asis);

        if(reg_asis.numero < numeroLimite) then begin
            Insert(caracter, reg_asis.apellido, 1); //coloca caracter al comienzo del string
            Seek(archivo, FilePos(archivo) - 1);
            Write(archivo, reg_asis);
        end;
    end;

    WriteLn('Baja finalizada.');
    WriteLn;

    Close(archivo);
end;

procedure imprimirAsistentes(var archivo: archivo_asistentes);
    procedure imprimir(reg: asistente);
    begin
        Writeln('Numero: ', reg.numero);
        Writeln('Apellido: ', reg.apellido);
        Writeln('Nombre: ', reg.nombre);
        Writeln('Email: ', reg.email);
        Writeln('Telefono: ', reg.telefono);
        Writeln('DNI: ', reg.dni);
        WriteLn;
    end;
var
    reg: asistente;
begin
    Reset(archivo);
    
    while(not Eof(archivo)) do begin
        Read(archivo, reg);

        imprimir(reg);
    end;

    Close(archivo);
end;

var
    archivo: archivo_asistentes;
    opcion: Integer;
begin
    Assign(archivo, 'asistentes');

    WriteLn;
    WriteLn('Ingrese opcion: ');
    WriteLn('1- Crear archivo');
    WriteLn('2- Baja logica de asistente');
    WriteLn('3- Imprimir asistentes');

    Write('=> ');
    ReadLn(opcion);
    WriteLn;

    case opcion of
        1: crearArchivo(archivo);

        2: bajaLogicaArchivo(archivo);

        3: imprimirAsistentes(archivo);

        else WriteLn('Opcion invalida');
    end;
end.