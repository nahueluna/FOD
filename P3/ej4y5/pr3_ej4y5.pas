program pr3_ej4y5;
type
    reg_flor = record
        nombre: String[45];
        codigo: Integer;
    end;

    tArchFlores = file of reg_flor;

procedure AsignarArchivo(var archivo: tArchFlores);
var
    path: String;
begin
    Write('Ingrese el nombre del archivo: ');
    ReadLn(path);
    Assign(archivo, path);
end;

procedure agregarFlor(var a: tArchFlores; nombre: String; codigo: Integer);
var
    reg_leido, reg_cabecera: reg_flor;
    pos: Integer;
begin
    Reset(a);

    reg_leido.nombre := nombre;
    reg_leido.codigo := codigo;
    pos := FileSize(a);

    Read(a, reg_cabecera);
    if(reg_cabecera.codigo < 0) then begin
        pos := Abs(reg_cabecera.codigo);
        Seek(a, pos);
        Read(a, reg_cabecera);
        Seek(a, 0);
        Write(a, reg_cabecera);
    end;

    Seek(a, pos);
    Write(a, reg_leido);

    WriteLn('Agregado correctamente.');
    WriteLn;

    Close(a);
end;

procedure listarFlores(var a: tArchFlores);
    procedure imprimirFlor(reg: reg_flor);
    begin
        with reg do begin
            WriteLn('Nombre: ', nombre);
            WriteLn('Codigo: ', codigo);
            WriteLn;
        end;
    end;
var
    reg: reg_flor;
begin
    Reset(a);

    while(not Eof(a)) do begin
        Read(a, reg);
        if(reg.codigo > 0) then imprimirFlor(reg);
    end;

    Close(a);
end;

procedure eliminarFlor(var a: tArchFlores; flor: reg_flor);
var
    reg_leido, reg_cabecera: reg_flor;
    encontrado: Boolean;
begin
    Reset(a);

    encontrado := false;

    Read(a, reg_cabecera);
    while(not Eof(a)) and (not encontrado) do begin
        Read(a, reg_leido);
        if(reg_leido.codigo = flor.codigo) then encontrado := true;
    end;

    if(encontrado) then begin
        Seek(a, FilePos(a) - 1);
        Write(a, reg_cabecera);
        
        reg_cabecera.codigo := (FilePos(a) - 1) * -1;
        Seek(a, 0);
        Write(a, reg_cabecera);
        
        WriteLn('Eliminado correctamente.');
    end
    else WriteLn('Elemento no encontrado.');

    WriteLn;

    Close(a);
end;

var
    archivo: tArchFlores;
    flor: reg_flor;
begin
    AsignarArchivo(archivo);

    listarFlores(archivo);

    flor.nombre := 'Tulipán';
    flor.codigo := 2;

    ReadLn;
    eliminarFlor(archivo, flor);

    listarFlores(archivo);

    flor.nombre := 'Margarita';
    flor.codigo := 8;

    agregarFlor(archivo, flor.nombre, flor.codigo);

    listarFlores(archivo);
end.