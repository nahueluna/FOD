program pr2_ej10;
const
    valorAlto = 'ZZZZ';
    DF = 15;
type
    rangoCategoria = 1..DF;

    empleado = record
        departamento: String[50];
        division: String[30];
        numero: Integer;
        categoria: rangoCategoria;
        horas: Integer;
    end;

    archivo_empleados = file of empleado;

    valorHoras = array[rangoCategoria] of Real;

procedure asignar(var maestro: archivo_empleados);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure leer(var maestro: archivo_empleados; var regM: empleado);
begin
    if(not Eof(maestro)) then Read(maestro, regM)
    else regM.departamento := valorAlto;
end;

procedure cargarMontoHoras(var monto_texto: Text; var vMontos: valorHoras);
var
    i, aux: Integer;
begin
    Reset(monto_texto);
    aux := 0;   //evitar warnings
    for i:= 1 to DF do
        ReadLn(monto_texto, aux, vMontos[aux]);

    Close(monto_texto); 
end;

procedure reportarHorasExtras(var maestro: archivo_empleados; montoHoras: valorHoras);
var
    regM: empleado;
    departamentoActual: String[50];
    divisionActual: String[30];
    horasDivision, horasDepartamento: Integer;
    montoDivision, montoDepartamento: Real;
begin
    Reset(maestro);

    leer(maestro, regM);

    while(regM.departamento <> valorAlto) do begin
        departamentoActual := regM.departamento;
        horasDepartamento := 0;
        montoDepartamento := 0;

        WriteLn('Departamento: ', departamentoActual);

        while(departamentoActual = regM.departamento) do begin
            divisionActual := regM.division;
            horasDivision := 0;
            montoDivision := 0;

            WriteLn('Division: ', divisionActual);

            //Se presupone que cada empleado aparece una vez en el archivo, pues es la contabilizacion de sus horas mensuales
            while(departamentoActual = regM.departamento) and (divisionActual = regM.division) do begin
                horasDivision := horasDivision + regM.horas;
                montoDivision := montoDivision + (regM.horas * montoHoras[regM.categoria]);

                WriteLn('Empleado: ', regM.numero, ' - Total de Hs: ', regM.horas, ' - Importe a cobrar: $', (regM.horas * montoHoras[regM.categoria]):0:2);

                leer(maestro, regM);
            end;

            horasDepartamento := horasDepartamento + horasDivision;
            montoDepartamento := montoDepartamento + montoDivision;

            WriteLn;
            WriteLn('Total de horas division: ', horasDivision);
            WriteLn('Monto total por division: $', montoDivision:0:2);
            WriteLn;

        end;
        WriteLn('--------------------');
        WriteLn('Total horas departamento: ', horasDepartamento);
        WriteLn('Monto total departamento: $', montoDepartamento:0:2);

        WriteLn;
        WriteLn;
    end;

    Close(maestro);
end;

var
    archivo_maestro: archivo_empleados;
    monto_horas_texto: Text;
    montoHoras: valorHoras;
begin
    asignar(archivo_maestro);
    Assign(monto_horas_texto, 'monto_horas_extra.txt');

    cargarMontoHoras(monto_horas_texto, montoHoras);

    WriteLn;

    reportarHorasExtras(archivo_maestro, montoHoras);
end.