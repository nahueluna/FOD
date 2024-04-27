program pr3_ej7;
const
    caracter = '@';
type
    ave = record
        codigo: Integer;
        especie: String[50];
        familia: String[50];
        desc: String;
        zona: String[50];
    end;

    arch_aves = file of ave;

procedure marcarArchivosEliminados(var archivo: arch_aves; cod: Integer);
var
    reg_ave: ave;
    encontrado: Boolean;
begin
    encontrado := false;

    while(not Eof(archivo)) and (not encontrado) do begin
        Read(archivo, reg_ave);
        if(reg_ave.codigo = cod) then encontrado := true;
    end;

    if(encontrado) then begin
        Insert(caracter, reg_ave.especie, 1);
        Seek(archivo, FilePos(archivo) - 1);
        Write(archivo, reg_ave);

        WriteLn('Baja realizada.');
    end
    else WriteLn('El codigo de ave ', cod, ' no se encuentra registrado.');

    WriteLn;
end;

procedure bajaLogicaArchivo(var archivo: arch_aves);
var
    cod_leido: Integer;
begin
    Reset(archivo);

    Writeln('Ingrese codigos de las aves a eliminar: ');
    ReadLn(cod_leido);
    
    while(cod_leido <> 5000) do begin
        marcarArchivosEliminados(archivo, cod_leido);

        ReadLn(cod_leido);
    end;

    WriteLn('Bajas logicas efectuadas.');
    WriteLn;

    Close(archivo);
end;

procedure compactarArchivo(var archivo: arch_aves);
var
    reg_leido: ave;
    posEliminado: Integer;
begin
    Reset(archivo);

    while(not Eof(archivo)) do begin
        Read(archivo, reg_leido);

        if(Pos(caracter, reg_leido.especie) > 0) then begin
            posEliminado := FilePos(archivo) - 1;
            Seek(archivo, FileSize(archivo) - 1);
            Read(archivo, reg_leido);
            Seek(archivo, posEliminado);
            Write(archivo, reg_leido);

            Seek(archivo, FileSize(archivo) - 1);
            Truncate(archivo);
            Seek(archivo, posEliminado); // Para evaluar el registro que acabo de reemplazar
        end;
    end;

    WriteLn('Compactacion finalizada.');
    WriteLn;

    Close(archivo);
end;

var
    archivo: arch_aves;
begin
    Assign(archivo, 'aves');

    bajaLogicaArchivo(archivo);

    compactarArchivo(archivo);
end.