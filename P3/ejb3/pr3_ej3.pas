program pr3_ej3;
const
    valorAlto = 9999;
    DF = 5;
type
    sesion = record
        cod_usuario: Integer;
        fecha: Integer;
        tiempo: Integer;
    end;

    sesiones = file of sesion;
    
    vector_detalles = array[1..DF] of sesiones;
    vector_reg_detalles = array[1..DF] of sesion;

procedure asignarDetalles(var det: vector_detalles);
var
    path, aux: String;
    i: Integer;
begin
    for i := 1 to DF do begin
        path := 'detalle_';
        Str(i, aux);
        path := path + aux;
        Assign(det[i], path);
    end;
end;

procedure leer(var archivo: sesiones; var reg: sesion);
begin
    if(not Eof(archivo)) then Read(archivo, reg)
    else reg.cod_usuario := valorAlto;
end;

procedure existeSesion(var maestro: sesiones; reg_sesion: sesion; var encontrado: Boolean; var pos: Integer);
var
    reg_mae: sesion;
begin
    Reset(maestro);

    encontrado := false;
    pos := -1;

    while(not Eof(maestro)) and (not encontrado) do begin
        Read(maestro, reg_mae);
        if(reg_sesion.cod_usuario = reg_mae.cod_usuario) and (reg_sesion.fecha = reg_mae.fecha) then begin
            encontrado := true;
            pos := FilePos(maestro) - 1;
        end;
    end;

    Close(maestro);
end;

procedure agregarOrdenado(var maestro: sesiones; reg_sesion: sesion);
    function evaluarCondicion(reg_maestro, reg_sesion: sesion): Boolean;
    var
        cod_menor, fecha_menor: Boolean;
    begin
        cod_menor := (reg_maestro.cod_usuario < reg_sesion.cod_usuario);
        fecha_menor := ((reg_maestro.cod_usuario = reg_sesion.cod_usuario) and (reg_maestro.fecha <= reg_sesion.fecha));

        evaluarCondicion := cod_menor or fecha_menor;
    end;
var
    reg_maestro: sesion;
    i, pos: Integer;
begin
    Reset(maestro);

    leer(maestro, reg_maestro);
    while(reg_maestro.cod_usuario <> valorAlto) and (evaluarCondicion(reg_maestro, reg_sesion)) do
        leer(maestro, reg_maestro);

    if(reg_maestro.cod_usuario <> valorAlto) then begin
        pos := FilePos(maestro) - 1;
        for i := (FileSize(maestro) - 1) downto pos do begin
            Seek(maestro, i);
            Read(maestro, reg_maestro);
            Write(maestro, reg_maestro);
        end;

        Seek(maestro, pos);
        Write(maestro, reg_sesion);
    end
    else Write(maestro, reg_sesion);

    Close(maestro);
end;

{Recorrer detalles hasta Eof (uno por vez). Tomo un registro, verifico si existe
en el maestro.
Si existe, lo actualizo. Si no existe, lo agrego ordenado.}
procedure generarMaestro(var maestro: sesiones; var detalles: vector_detalles);
var
    reg_detalle: sesion;
    reg_maestro: sesion;
    i, pos_maestro: Integer;
    existe: Boolean;
begin
    Rewrite(maestro);
    Close(maestro);

    for i := 1 to DF do begin
        Reset(detalles[i]);

        while(not Eof(detalles[i])) do begin
            Read(detalles[i], reg_detalle);
            existeSesion(maestro, reg_detalle, existe, pos_maestro);

            if(existe) then begin
                Reset(maestro);
                Seek(maestro, pos_maestro);
                Read(maestro, reg_maestro);
                reg_maestro.tiempo := reg_maestro.tiempo + reg_detalle.tiempo;
                Seek(maestro, FilePos(maestro) - 1);
                Write(maestro, reg_maestro);
                Close(maestro);
            end
            else agregarOrdenado(maestro, reg_detalle);
        end;

        Close(detalles[i]);
    end;
end;

var
    maestro: sesiones;
    detalles: vector_detalles;
begin
    Assign(maestro, 'maestro_sesiones');
    asignarDetalles(detalles);

    generarMaestro(maestro, detalles);
end.