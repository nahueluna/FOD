program pr3_ej8;
type
    distribucion = record
        nombre: String[50];
        anio: Integer;
        version: Integer;
        cant_devs: Integer;
        desc: String;
    end;

    distribuciones = file of distribucion;

procedure existeDistribucion(var archivo: distribuciones; nombre: String; var encontrado: Boolean);
var
    reg_distro: distribucion;
begin
    Reset(archivo);

    encontrado := false;

    while(not Eof(archivo)) and (not encontrado) do begin
        Read(archivo, reg_distro);

        if(reg_distro.nombre = nombre) then encontrado := true;
    end;

    Close(archivo);
end;

procedure altaDistribucion(var archivo: distribuciones);
    procedure leerDistro(var reg: distribucion);
    begin
        with reg do begin
            Write('Nombre: '); ReadLn(nombre);
            Write('Anio lanzamiento: '); ReadLn(anio);
            Write('Version: '); ReadLn(version);
            Write('Cantidad desarrolladores: '); ReadLn(cant_devs);
            Write('Descripcion: '); ReadLn(desc);
            WriteLn;
        end;
    end;  
var
    reg_distro, reg_leido: distribucion;
    existe: Boolean;
    pos: Integer;
begin
    Writeln('Ingrese los datos de la distribucion a agregar');
    leerDistro(reg_leido);

    existeDistribucion(archivo, reg_leido.nombre, existe);

    if(not existe) then begin
        Reset(archivo);

        pos := FileSize(archivo) - 1;

        Read(archivo, reg_distro);
        if(reg_distro.cant_devs < 0) then begin
            pos := Abs(reg_distro.cant_devs);
            Seek(archivo, pos);
            Read(archivo, reg_distro);
            Seek(archivo, 0);
            Write(archivo, reg_distro);
        end;

        Seek(archivo, pos);
        Write(archivo, reg_leido);

        Close(archivo);
    end
    else WriteLn('La distribucion ya existe.');

    WriteLn;
end;

procedure bajaDistribucion(var archivo: distribuciones);
var
    reg_cabecera, reg_distro: distribucion;
    existe: Boolean;
    nombre_leido: String;
begin
    Write('Ingrese el nombre de la distribucion a eliminar: ');
    ReadLn(nombre_leido);

    existeDistribucion(archivo, nombre_leido, existe);
    
    if(existe) then begin
        Reset(archivo);

        Read(archivo, reg_cabecera);
        Read(archivo, reg_distro);
        while(reg_distro.nombre <> nombre_leido) do
            Read(archivo, reg_distro);

        Seek(archivo, FilePos(archivo) - 1);
        Write(archivo, reg_cabecera);

        reg_cabecera.cant_devs := (FilePos(archivo) - 1) * -1;
        Seek(archivo, 0);
        Write(archivo, reg_cabecera);

        Close(archivo);
    end
    else WriteLn('La distribucion no existe.');

    WriteLn;
end;

var
    archivo_distros: distribuciones;
begin
    Assign(archivo_distros, 'distribuciones');

    altaDistribucion(archivo_distros);

    bajaDistribucion(archivo_distros);
end.