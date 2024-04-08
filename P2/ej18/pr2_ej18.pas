program pr2_ej18;
const
    valorAlto = 9999;
    DF = 49;
type
    rDireccion = record
        calle: String[30];
        nro: Integer;
        piso: String[10];
        depto: String[20];
        ciudad: String[30];
    end;

    datos_progenitor = record
        nombre: String[30];
        apellido: String[30];
        DNI: LongInt;
    end;

    acta_nacimiento = record
        nro_partida: Integer;
        nombre: String[30];
        apellido: String[30];
        direccion: rDireccion;
        matricula_medico: Integer;
        madre: datos_progenitor;
        padre: datos_progenitor;
    end;

    acta_fallecimiento = record
        nro_partida: Integer;
        DNI: LongInt;
        nombre: String[30];
        apellido: String[30];
        matricula_medico: Integer;
        fecha: Integer;
        hora: Integer;
        lugar: String[50];
    end;

    acta_maestra = record
        nro_partida: Integer;
        nombre: String[30];
        apellido: String[30];
        direccion: rDireccion;
        matricula_medico: Integer;
        madre: datos_progenitor;
        padre: datos_progenitor;
        fallecido: Boolean;
        matricula_med_deceso: Integer;
        fecha: Integer;
        hora: Integer;
        lugar: String[50];
    end;

    detalle_nacimientos = file of acta_nacimiento;
    detalle_fallecimientos = file of acta_fallecimiento;
    archivo_maestro = file of acta_maestra;

    vector_nacimientos = array[0..DF] of detalle_nacimientos;
    vector_fallecimientos = array[0..DF] of detalle_fallecimientos;

    vector_reg_nacimientos = array[0..DF] of acta_nacimiento;
    vector_reg_fallecimientos = array[0..DF] of acta_fallecimiento;

procedure asignarMaestro(var maestro: archivo_maestro);
var
    path: String;
begin
    Write('Ingresar nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure asignarNacimientos(var nacimientos: vector_nacimientos);
var
    path, aux: String;
    i: Integer;
begin
    for i := 0 to DF do begin
        path := 'nacimientos_';
        Str(i, aux);
        path := path + aux;
        Assign(nacimientos[i], path);
    end;
end;

procedure asignarFallecimientos(var fallecimientos: vector_fallecimientos);
var
    path, aux: String;
    i: Integer;
begin
    for i := 0 to DF do begin
        path := 'fallecimientos_';
        Str(i, aux);
        path := path + aux;
        Assign(fallecimientos[i], path);
    end;
end;

procedure leerNacimiento(var det_nacimiento: detalle_nacimientos; var reg_detalle: acta_nacimiento);
begin
    if(not Eof(det_nacimiento)) then Read(det_nacimiento, reg_detalle)
    else reg_detalle.nro_partida := valorAlto;
end;

procedure leerFallecimiento(var det_fallecimiento: detalle_fallecimientos; var reg_detalle: acta_fallecimiento);
begin
    if(not Eof(det_fallecimiento)) then Read(det_fallecimiento, reg_detalle)
    else reg_detalle.nro_partida := valorAlto;
end;

procedure minimoNacimiento(var nacimientos: vector_nacimientos; var reg_nacimientos: vector_reg_nacimientos; var regMin: acta_nacimiento);
var
    i, minPos: Integer;
begin
    regMin.nro_partida := valorAlto;

    for i := 0 to DF do begin
        if(reg_nacimientos[i].nro_partida < regMin.nro_partida) then begin
            regMin := reg_nacimientos[i];
            minPos := i;
        end;
    end;

    if(regMin.nro_partida <> valorAlto) then
        leerNacimiento(nacimientos[minPos], reg_nacimientos[minPos]);
end;

procedure minimoFallecimiento(var fallecimientos: vector_fallecimientos; var reg_fallecimientos: vector_reg_fallecimientos; var regMin: acta_fallecimiento);
var
    i, minPos: Integer;
begin
    regMin.nro_partida := valorAlto;

    for i := 0 to DF do begin
        if(reg_fallecimientos[i].nro_partida < regMin.nro_partida) then begin
            regMin := reg_fallecimientos[i];
            minPos := i;
        end;
    end;

    if(regMin.nro_partida <> valorAlto) then
        leerFallecimiento(fallecimientos[minPos], reg_fallecimientos[minPos]);
end;

procedure generarArchivoMaestro(var maestro: archivo_maestro; var nacimientos: vector_nacimientos; var fallecimientos: vector_fallecimientos; var actas_texto: Text);
    procedure escribirMaestro(var regM: acta_maestra; regMinNa: acta_nacimiento; regMinFa: acta_fallecimiento);
    begin
        regM.nro_partida := regMinNa.nro_partida;
        regM.nombre := regMinNa.nombre;
        regM.apellido := regMinNa.apellido;
        regM.direccion := regMinNa.direccion;
        regM.matricula_medico := regMinNa.matricula_medico;
        regM.madre := regMinNa.madre;
        regM.padre := regMinNa.padre;
        regM.fallecido := (regMinNa.nro_partida = regMinFa.nro_partida);

        if(regM.fallecido) then begin
            regM.matricula_med_deceso := regMinFa.matricula_medico;
            regM.fecha := regMinFa.fecha;
            regM.hora := regMinFa.hora;
            regM.lugar := regMinFa.lugar;
        end;
    end;

    procedure exportarTexto(regM: acta_maestra; var texto: Text);
    begin
        with regM do begin
            WriteLn(texto, nro_partida);
            WriteLn(texto, nombre);
            WriteLn(texto, apellido);
            WriteLn(texto, direccion.calle, ' ', direccion.nro, ' ', direccion.piso, ' ', direccion.depto, ' ', direccion.ciudad);
            WriteLn(texto, matricula_medico);
            WriteLn(texto, madre.DNI, ' ', madre.nombre);
            WriteLn(texto, madre.apellido);
            WriteLn(texto, padre.DNI, ' ', padre.nombre);
            WriteLn(texto, padre.apellido);

            if(fallecido) then begin
                WriteLn(texto, matricula_med_deceso, ' ', fecha, ' ', hora);
                WriteLn(texto, lugar);
            end;
        end;
    end;

var
    reg_nacimientos: vector_reg_nacimientos;
    reg_fallecimientos: vector_reg_fallecimientos;
    regM: acta_maestra;
    regMinNa: acta_nacimiento;
    regMinFa: acta_fallecimiento;
    i: Integer;
begin
    Rewrite(maestro);
    for i := 0 to DF do begin
        Reset(nacimientos[i]);
        Reset(fallecimientos[i]);
        leerNacimiento(nacimientos[i], reg_nacimientos[i]);
        leerFallecimiento(fallecimientos[i], reg_fallecimientos[i]);
    end;
    Rewrite(actas_texto);

    minimoNacimiento(nacimientos, reg_nacimientos, regMinNa);
    minimoFallecimiento(fallecimientos, reg_fallecimientos, regMinFa);

    //cantidad nacidos >= cantidad fallecidos
    while(regMinNa.nro_partida <> valorAlto) do begin
        escribirMaestro(regM, regMinNa, regMinFa);

        Write(maestro, regM);

        exportarTexto(regM, actas_texto);

        minimoNacimiento(nacimientos, reg_nacimientos, regMinNa);
        if(regMinFa.nro_partida <> valorAlto) and (regMinNa.nro_partida > regMinFa.nro_partida) then 
            minimoFallecimiento(fallecimientos, reg_fallecimientos, regMinFa);
    end;

    WriteLn('Generacion de archivo maestro finalizada.');

    Close(actas_texto);
    for i := DF downto 0 do begin
        Close(fallecimientos[i]);
        Close(nacimientos[i]);
    end;
    Close(maestro);
end;

var
    maestro: archivo_maestro;
    nacimientos: vector_nacimientos;
    fallecimientos: vector_fallecimientos;
    maestro_texto: Text;
begin
    asignarMaestro(maestro);
    asignarNacimientos(nacimientos);
    asignarFallecimientos(fallecimientos);
    Assign(maestro_texto, 'nacimientos_y_fallecimientos.txt');

    WriteLn;

    generarArchivoMaestro(maestro, nacimientos, fallecimientos, maestro_texto);
end.