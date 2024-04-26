program pr3_ej6;
const
    nombre_archivo = 'prendas';
type
    prenda = record
        codigo: Integer;
        desc: String;
        colores: String[50];
        tipo: Integer;
        stock: Integer;
        precio_u: Real;
    end;

    prendas = file of prenda;
    codigos_prendas = file of Integer;

procedure eliminarPrendas(var maestro: prendas; var codigos: codigos_prendas);
var
    reg_prenda: prenda;
    cod: Integer;
    encontrado: boolean;
begin
    Reset(maestro);
    Reset(codigos);

    while(not Eof(codigos)) do begin
        Read(codigos, cod);

        encontrado := false;

        while(not Eof(maestro)) and (not encontrado) do begin
            Read(maestro, reg_prenda);
            if(reg_prenda.codigo = cod) then encontrado := true;
        end;

        if(encontrado) then begin
            Seek(maestro, FilePos(maestro) - 1);
            reg_prenda.stock := reg_prenda.stock * -1;
            Write(maestro, reg_prenda);
        end
        else WriteLn('Codigo ', cod, ' no encontrado.');

        Seek(maestro, 0);
    end;

    Close(codigos);
    Close(maestro);
end;

procedure compactarArchivo(var maestro, maestro_nuevo: prendas);
var
    reg_prenda: prenda;
begin
    Assign(maestro_nuevo, 'new_master');
    Rewrite(maestro_nuevo);
    Reset(maestro);

    while(not Eof(maestro)) do begin
        Read(maestro, reg_prenda);
        if(reg_prenda.stock > 0) then Write(maestro_nuevo, reg_prenda);
    end;

    Close(maestro);
    Close(maestro_nuevo);
    Erase(nombre_archivo);  //borro el anterior archivo maestro
    Rename(maestro_nuevo, nombre_archivo);  //renombro el nuevo maestro con el nombre del anterior
end;

var
    maestro, maestro_nuevo: prendas;
    cod_prendas: codigos_prendas;
begin
    Assign(maestro, nombre_archivo);
    Assign(cod_prendas, 'codigos');

    eliminarPrendas(maestro, cod_prendas);

    compactarArchivo(maestro, maestro_nuevo);
end.