program pr2_ej4;
const
    valorAlto = 'ZZZ';
type
    censo = record
        provincia: String[15];
        cantidad_alfabetizados: Integer;
        cantidad_encuestados: Integer;
    end;

    info_censo = record
        provincia: String[15];
        codigo_localidad: String[10];
        cantidad_alfabetizados: Integer;
        cantidad_encuestados: Integer;
    end;

    archivo_censo = file of censo;
    detalle_censo = file of info_censo;

procedure asignarMaestro(var maestro: archivo_censo);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure asignarDetalle(var detalle: detalle_censo);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo detalle: ');
    ReadLn(path);
    Assign(detalle, path);
end;

procedure leer(var detalle: detalle_censo; var regDetalle: info_censo);
begin
    if(not Eof(detalle)) then Read(detalle, regDetalle)
    else regDetalle.provincia := valorAlto;
end;

//Guarda y lee el registro con criterio de ordenacion (provincia en este caso) minimo y vuelve a leer del mismo
//Cuando cambie de provincia, cambiará el minimo y se leerá el otro. Asi se asegura leer todos los registros de
//una misma provincia, aunque estén en archivos distintos (calculo mínimo y vuelvo a leer del que fue mínimo)
procedure minimo(var regD1, regD2, regMin: info_censo; var detalle1, detalle2: detalle_censo);
begin
    if(regD1.provincia <= regD2.provincia) then begin
        regMin := regD1;
        leer(detalle1, regD1);
    end
    else begin
        regMin := regD2;
        leer(detalle2, regD2);
    end;
end;

procedure actualizarMaestro(var maestro: archivo_censo; var detalle1: detalle_censo; var detalle2: detalle_censo);
var
    regD1, regD2, regMin: info_censo;
    regM: censo;
begin
    Reset(maestro);
    Reset(detalle1);
    Reset(detalle2);

    leer(detalle1, regD1);
    leer(detalle2, regD2);
    minimo(regD1, regD2, regMin, detalle1, detalle2);

    while(regMin.provincia <> valorAlto) do begin
        Read(maestro, regM);
        
        while(regMin.provincia <> regM.provincia) do
            Read(maestro, regM);
        
        while(regM.provincia = regMin.provincia) do begin
            regM.cantidad_alfabetizados := regM.cantidad_alfabetizados + regMin.cantidad_alfabetizados;
            regM.cantidad_encuestados := regM.cantidad_encuestados + regMin.cantidad_encuestados;
            minimo(regD1, regD2, regMin, detalle1, detalle2);
        end;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);
    end;


    Close(detalle2);
    Close(detalle1);
    Close(maestro);
end;

var
    archivo_maestro: archivo_censo;
    archivo_detalle1, archivo_detalle2: detalle_censo; 
begin
    asignarMaestro(archivo_maestro);
    asignarDetalle(archivo_detalle1);
    asignarDetalle(archivo_detalle2);

    actualizarMaestro(archivo_maestro, archivo_detalle1, archivo_detalle2);
end.