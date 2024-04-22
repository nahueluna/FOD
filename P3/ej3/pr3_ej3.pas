program pr3_ej3;
type
    novela = record
        codigo: Integer;
        genero: String[30];
        nombre: String[100];
        duracion: Integer;
        director: String[50];
        precio: Real;
    end;

    archivo_novelas = file of novela;

procedure asignarArchivo(var archivo: archivo_novelas);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo: ');
    ReadLn(path);
    Assign(archivo, path);
end;

procedure leerNovela(var reg: novela);
    begin
        with reg do begin
            Write('Codigo: '); ReadLn(codigo);
            if(codigo > 0) then begin
                Write('Genero: '); ReadLn(genero);
                Write('Nombre: '); ReadLn(nombre);
                Write('Duracion: '); ReadLn(duracion);
                Write('Director: '); ReadLn(director);
                Write('Precio: '); ReadLn(precio);
            end;
            WriteLn;
        end;
    end;

procedure crearArchivo(var archivo: archivo_novelas);
var
    reg_novela: novela;
begin
    Rewrite(archivo);
    
    WriteLn('Ingreso de novelas: ');

    // Inicializo para evitar corrupcion por datos basura en el archivo texto cuando se exporte
    reg_novela := Default(novela);
    Write(archivo, reg_novela);

    leerNovela(reg_novela);
    while(reg_novela.codigo <> -1) do begin
        Write(archivo, reg_novela);
        leerNovela(reg_novela);
    end;

    WriteLn('Creacion de archivo finalizada.');

    Close(archivo);
end;

// Se presupone que la novela ingresada es distinta de las ya guardadas, ya que
// verificarlo implicaria un recorrido secuencial que no aprovecharia la
// utilizacion de una lista invertida
procedure agregarNovela(var archivo: archivo_novelas);
var
    reg_cabecera, novela_leida: novela;
    pos: Integer;
begin
    Reset(archivo);

    // Si codigo novela es positivo es valido
    leerNovela(novela_leida);
    if(novela_leida.codigo > 0) then begin
        pos := FileSize(archivo);   // Asigno ultima posicion del archivo
        
        // Si codigo registro cabecera < 0 hay espacio libre
        Read(archivo, reg_cabecera);
        if(reg_cabecera.codigo < 0) then begin
            pos := Abs(reg_cabecera.codigo);
            Seek(archivo, pos);
            Read(archivo, reg_cabecera);  // Tomo archivo borrado con enlace a siguiente elemento borrado
            Seek(archivo, 0);
            Write(archivo, reg_cabecera); // Lo guardo en la cabecera
        end;

        Seek(archivo, pos); // Voy a ultima posicion o lugar libre (si entré al if)
        Write(archivo, novela_leida);
    end
    else WriteLn('El codigo de la novela no es valido para su ingreso.');

    WriteLn('Proceso de alta finalizado');
    WriteLn;

    Close(archivo);
end;

procedure modificarNovela(var archivo: archivo_novelas);
var
    reg_novela, novela_leida: novela;
    modificado: Boolean;
begin
    Reset(archivo);
    
    modificado := false;

    WriteLn('Ingrese el codigo de la novela a modificar y sus nuevos datos');
    leerNovela(novela_leida);
    
    if(novela_leida.codigo > 0) then begin
        while(not Eof(archivo)) and (not modificado) do begin
            Read(archivo, reg_novela);

            if(reg_novela.codigo = novela_leida.codigo) then begin
                Seek(archivo, FilePos(archivo) - 1);
                Write(archivo, novela_leida);
                modificado := true;
            end;
        end;
    end;

    if(modificado) then WriteLn('Modificacion efectuada.')
    else WriteLn('La novela no se encuentra en el archivo.');

    WriteLn;

    Close(archivo);
end;

procedure eliminarNovela(var archivo: archivo_novelas);
var
    reg_cabecera, reg_novela: novela;
    cod_novela: Integer;
    encontrado: Boolean;
begin
    Reset(archivo);

    encontrado := false;

    Write('Ingrese el codigo de la novela a eliminar: ');
    ReadLn(cod_novela);

    Read(archivo, reg_cabecera);    // Leo registro de cabecera del archivo
    while(not Eof(archivo)) and (not encontrado) do begin
        Read(archivo, reg_novela);

        if(reg_novela.codigo = cod_novela) then encontrado := true;
    end;

    if(encontrado) then begin
        Seek(archivo, FilePos(archivo) - 1);
        Write(archivo, reg_cabecera);
        
        reg_novela.codigo := (FilePos(archivo) - 1) * -1; // Posicion borrada negativa
        Seek(archivo, 0);
        Write(archivo, reg_novela);

        WriteLn('Novela eliminada correctamente.');
    end
    else WriteLn('Codigo de novela no encontrado.');

    WriteLn;

    Close(archivo);
end;

procedure abrirArchivo(var archivo: archivo_novelas);
var
    opcion: Integer;
begin
    WriteLn;
    WriteLn('Archivo abierto');
    WriteLn('Elija una de las operaciones a continuacion: ');
    WriteLn('1- Agregar una novela');
    WriteLn('2- Modificar una novela');
    WriteLn('3- Eliminar una novela');
    WriteLn('4- Salir');
    WriteLn;

    Write('=> ');
    ReadLn(opcion);
    WriteLn;

    case opcion of
        1: agregarNovela(archivo);

        2: modificarNovela(archivo);

        3: eliminarNovela(archivo);

        else WriteLn('Opcion ingresada no valida');
    end;
end;

procedure exportarArchivo(var archivo: archivo_novelas; var texto: Text);
    procedure escribirTexto(var texto: Text; reg:novela);
    begin
        with reg do begin
            WriteLn(texto, codigo, ' | ', genero);
            WriteLn(texto, duracion, ' | ', nombre);
            WriteLn(texto, precio:0:2, ' | ', director);
        end;
    end;
var
    reg_novela: novela;
begin
    Assign(texto, 'novelas.txt');
    Rewrite(texto);
    Reset(archivo);

    while(not Eof(archivo)) do begin
        Read(archivo, reg_novela);
        escribirTexto(texto, reg_novela);
    end;

    WriteLn('Archivo exportado correctamente.');
    WriteLn;

    Close(archivo);
    Close(texto);
end;

procedure callMenu(var archivo: archivo_novelas; var texto: Text);
    procedure printMenu();
    begin
        WriteLn;
        WriteLn('Menu de archivo novelas');
        WriteLn('Ingrese una opcion: ');
        WriteLn('1- Crear archivo');
        WriteLn('2- Abrir archivo');
        WriteLn('3- Exportar a texto');
        WriteLn('4- Salir');
        WriteLn;
        Write('=> ');
    end;
var
    opcion: Integer;
begin
    printMenu;
    ReadLn(opcion);
    WriteLn;

    while(opcion <> 4) do begin
        case opcion of
            1: crearArchivo(archivo);

            2: abrirArchivo(archivo);

            3: exportarArchivo(archivo, texto);

            else WriteLn('Opcion ingresada no valida');
        end;

        printMenu;
        ReadLn(opcion);
        WriteLn;
    end;
end;

var
    archivo: archivo_novelas;
    texto: Text;
begin
    asignarArchivo(archivo);
    
    WriteLn;

    callMenu(archivo, texto);
end.