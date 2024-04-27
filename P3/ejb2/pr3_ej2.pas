program pr3_ej2;
const
    valorAlto = 9999;
type
    mesa = record
        cod_localidad: Integer;
        numero: Integer;
        cant_votos: Integer;
    end;

    archivo_mesas = file of mesa;
    archivo_codigos = file of Integer;

procedure leer(var archivo: archivo_mesas; var reg: mesa);
begin
    if(not Eof(archivo)) then Read(archivo, reg)
    else reg.cod_localidad := valorAlto;
end;

procedure existeLocalidad(var archivo: archivo_codigos; cod_leido: Integer; var encontrado: Boolean);
var
    cod_actual: Integer;
begin
    Reset(archivo);

    encontrado := false;

    while(not Eof(archivo)) and (not encontrado) do begin
        Read(archivo, cod_actual);
        if(cod_actual = cod_leido) then encontrado := true;
    end;

    Close(archivo);
end;

procedure listarMesas(var maestro: archivo_mesas);
    procedure crearArchivoLocalidades(var a: archivo_codigos);
    begin
        Assign(a, 'mesas_procesadas');
        Rewrite(a);
        Close(a);
    end;

    procedure agregarLocalidad(var arch_local: archivo_codigos; cod: Integer);
    begin
        Reset(arch_local);

        Seek(arch_local, FileSize(arch_local));
        Write(arch_local, cod);

        Close(arch_local);
    end;
var
    localidades_leidas: archivo_codigos;
    reg_mesa: mesa;
    cod_actual, pos_archivo, cantVotos, totalVotos: Integer;
    existe: Boolean;
begin
    crearArchivoLocalidades(localidades_leidas);
    Reset(maestro);

    totalVotos := 0;

    leer(maestro, reg_mesa);
    while(reg_mesa.cod_localidad <> valorAlto) do begin
        existeLocalidad(localidades_leidas, reg_mesa.cod_localidad, existe);

        if(not existe) then begin
            pos_archivo := FilePos(maestro);
            agregarLocalidad(localidades_leidas, reg_mesa.cod_localidad);
            cod_actual := reg_mesa.cod_localidad;

            cantVotos := 0;
            while(reg_mesa.cod_localidad <> valorAlto) do begin
                if(reg_mesa.cod_localidad = cod_actual) then 
                    cantVotos := cantVotos + reg_mesa.cant_votos;
                leer(maestro, reg_mesa);
            end;
            totalVotos := totalVotos + cantVotos;
            if(pos_archivo < FileSize(maestro)) then begin
                Seek(maestro, pos_archivo); // vuelvo a la posicion siguiente al codigo de localidad procesado
                leer(maestro, reg_mesa);
            end;

            WriteLn('Codigo localidad: ', cod_actual);
            WriteLn(#9, 'Total de votos: ', cantVotos);
        end
        else leer(maestro, reg_mesa);
    end;

    WriteLn;
    WriteLn('Total general de votos: ', totalVotos);

    Close(maestro);
end;

procedure crearArchivo(var a: archivo_mesas);
    procedure leerMesa(var reg: mesa);
    begin
        with reg do begin
            WriteLn('Codigo localidad: '); ReadLn(cod_localidad);
            WriteLn('Numero mesa: '); ReadLn(numero);
            WriteLn('Cantidad de votos: '); ReadLn(cant_votos);
            WriteLn;
        end;
    end;
var
    reg: mesa;
begin
    Rewrite(a);

    leerMesa(reg);
    while(reg.cod_localidad <> -1) do begin
        Write(a, reg);
        leerMesa(reg);
    end;

    WriteLn;

    Close(a);
end;

var
    archivo: archivo_mesas;
begin
    Assign(archivo, 'mesas_electorales');

    //crearArchivo(archivo);

    WriteLn;

    listarMesas(archivo);
end.