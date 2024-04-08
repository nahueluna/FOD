program pr2_ej12;
const
    valorAlto = 9999;
type
    log = record
        nro_usuario: Integer;
        nombre_usuario: String[20];
        nombre: String[30];
        apellido: String[30];
        mails_enviados: Integer;
    end;

    info_log = record
        nro_usuario: Integer;
        cuenta_destino: String[50];
        mensaje: String;
    end;

    archivo_logs = file of log;
    detalle_logs = file of info_log;

procedure asignarDetalle(var detalle: detalle_logs);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo detalle del dia deseado: ');
    ReadLn(path);
    Assign(detalle, path);
end;

procedure leer(var detalle: detalle_logs; var regD:info_log);
begin
    if(not Eof(detalle)) then Read(detalle, regD)
    else regD.nro_usuario := valorAlto;
end;

procedure actualizarMaestroI(var maestro: archivo_logs; var detalle: detalle_logs);
var
    regM: log;
    regD: info_log;
begin
    Reset(maestro);
    Reset(detalle);

    leer(detalle, regD);
    while(regD.nro_usuario <> valorAlto) do begin
        Read(maestro, regM);
        while(regM.nro_usuario <> regD.nro_usuario) do
            Read(maestro, regM);

        while(regD.nro_usuario = regM.nro_usuario) do begin
            regM.mails_enviados := regM.mails_enviados + 1;
            leer(detalle, regD);
        end;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);
    end;

    WriteLn('Actualizacion finalizada');

    Close(detalle);
    Close(maestro);
end;

//Se exporta la cantidad de mails de todos los usuarios enviados en el dia correspondiente al detalle (aparezcan en él o no)
procedure exportarTexto(var maestro: archivo_logs; var detalle: detalle_logs; var logs_texto: Text);
var
    regM: log;
    regD: info_log;
    cantMails: Integer;
begin
    Reset(maestro);
    Reset(detalle);
    Rewrite(logs_texto);

    leer(detalle, regD);

    while(not Eof(maestro)) do begin
        Read(maestro, regM);
        while(regD.nro_usuario <> valorAlto) and (regD.nro_usuario < regM.nro_usuario) do
            leer(detalle, regD);
        
        cantMails := 0;
        while(regM.nro_usuario = regD.nro_usuario) do begin
            cantMails := cantMails + 1;
            leer(detalle, regD);
        end;

        WriteLn(logs_texto, regM.nro_usuario, ' ', cantMails);
    end;

    WriteLn('Exportacion finalizada');

    Close(logs_texto);
    Close(detalle);
    Close(maestro);
end;

procedure actualizarMaestroII(var maestro: archivo_logs; var detalle: detalle_logs; var logs_texto: Text);
var
    regM: log;
    regD: info_log;
    cantMails: Integer;
begin
    Reset(maestro);
    Reset(detalle);
    Rewrite(logs_texto);

    leer(detalle, regD);

    while(not Eof(maestro)) do begin
        Read(maestro, regM);

        cantMails := 0;
        while(regM.nro_usuario = regD.nro_usuario) do begin
            cantMails := cantMails + 1;
            leer(detalle, regD);
        end;

        WriteLn(logs_texto, regM.nro_usuario, ' ', cantMails);
        
        //evita sobreescribir registros sin actualizar
        if(cantMails > 0) then begin
            regM.mails_enviados := regM.mails_enviados + cantMails;
            Seek(maestro, FilePos(maestro) - 1);
            Write(maestro, regM);
        end;
    end;

    WriteLn('Actualizacion y exportacion finalizadas');

    Close(logs_texto);
    Close(detalle);
    Close(maestro);
end;

var
    maestro: archivo_logs;
    detalle: detalle_logs;
    logs_texto: Text;
    opcion: Integer;
begin
    Assign(maestro, './var/log/logmail.dat');
    asignarDetalle(detalle);
    Assign(logs_texto, 'logs_diarios.txt');

    WriteLn('Actualizacion y exportacion');
    WriteLn('1- Actualizacion y exportacion separadas');
    WriteLn('2- Actualizacion y exportacion unificadas');

    Write('=> ');
    ReadLn(opcion);
    WriteLn;

    //Actualiza y exporta a texto por separado
    if(opcion = 1) then begin
        actualizarMaestroI(maestro, detalle);
        exportarTexto(maestro, detalle, logs_texto);
    end
    //Actualiza y exporta a texto en el mismo módulo
    else if(opcion = 2) then
        actualizarMaestroII(maestro, detalle, logs_texto)
    else
        WriteLn('Opcion elegida no valida');
end.