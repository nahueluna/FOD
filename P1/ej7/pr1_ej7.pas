program pr1_ej7;
type
    novela = record
        codigo : Integer;
        nombre : String[50];
        genero : String[15];
        precio : Real;
    end;

    novelas = file of novela;

    options = 1..5;

procedure asignar(var arch_nov:novelas);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo: ');
    ReadLn(path);

    Assign(arch_nov, path);
end;

procedure crearArchivo(var arch_nov: novelas);
var
    novela_txt: Text;
    regNov: novela;
begin
    Assign(novela_txt, 'novelas.txt');
    Reset(novela_txt);

    Rewrite(arch_nov);
    
    while(not Eof(novela_txt)) do begin
        with regNov do begin
            Readln(novela_txt, codigo, precio, genero);
            ReadLn(novela_txt, nombre);
        end;
        Write(arch_nov, regNov);
    end;

    WriteLn('Archivo de novelas creado');

    Close(arch_nov);
    Close(novela_txt);
end;

procedure agregarNovela(var arch_nov: novelas);
    procedure leerNovela(var reg: novela);
    begin
        with reg do begin
            Write('Codigo: '); ReadLn(codigo);
            Write('Nombre: '); ReadLn(nombre);
            Write('Genero: '); ReadLn(genero);
            Write('Precio: '); ReadLn(precio);
        end;
    end;
    
    procedure existeNovela(var arch_nov: novelas; codNov: Integer; var encontrado: boolean);
    var
        reg: novela;
    begin
        encontrado := false;
        //Seek(arch_nov, 0);

        while((not Eof(arch_nov)) and (not encontrado)) do begin
            Read(arch_nov, reg);
            if(reg.codigo = codNov) then encontrado := true;
        end;
    end;
var
    regNov: novela;
    encontrado: boolean;
begin
    WriteLn('Ingreso de novelas');
    
    leerNovela(regNov);
    existeNovela(arch_nov, regNov.codigo, encontrado);
    
    if(not encontrado) then Write(arch_nov, regNov)
    else WriteLn('La novela ya esta registrada');

    WriteLn;
    WriteLn('Proceso de agregado finalizado');
    WriteLn;
end;

procedure modificarNovela(var arch_nov: novelas);
    procedure buscarNovela(var arch_nov: novelas; var regNov: novela; var encontrada: boolean);
    var
        codigoLeido: Integer;
    begin
        encontrada := false;
        
        Write('Ingrese el codigo de la novela a modificar: ');
        ReadLn(codigoLeido);

        while((not Eof(arch_nov)) and (not encontrada)) do begin
            Read(arch_nov, regNov);
            if(regNov.codigo = codigoLeido) then begin
                 encontrada := true;
                 Seek(arch_nov, FilePos(arch_nov)-1);
            end;
        end;
    end;
var
    eleccion: options;
    regNov: novela;
    encontrada: boolean;
begin
    buscarNovela(arch_nov, regNov, encontrada);
    
    if(encontrada) then begin
        while true do begin
            WriteLn;
            WriteLn('Elija que apartado de la novela quiere modificar');
            WriteLn('1- Codigo');
            WriteLn('2- Nombre');
            WriteLn('3- Genero');
            WriteLn('4- Precio');
            WriteLn('5- Salir');
            WriteLn;

            Write('=> ');
            ReadLn(eleccion);
            WriteLn;

            case eleccion of
                1: begin
                    Write('Ingrese el nuevo codigo: ');
                    ReadLn(regNov.codigo);
                end;

                2: begin
                    Write('Ingrese el nuevo nombre: ');
                    ReadLn(regNov.nombre);
                end;

                3: begin
                    Write('Ingrese el nuevo genero: ');
                    ReadLn(regNov.genero);
                end;

                4: begin
                    Write('Ingrese el nuevo precio: ');
                    ReadLn(regNov.precio);
                end;

                5: break

                else WriteLn('La opcion ingresada no es valida');

            end;
        end;

        Write(arch_nov, regNov);

    end
    else WriteLn('La novela solicitada no se encuentra registrada');

    WriteLn('Proceso de actualizacion finalizado');
end;

procedure imprimir(var arch_nov: novelas);
    procedure escribirNovela(reg: novela);
    begin
        with reg do begin
            WriteLn('Codigo: ', codigo);
            WriteLn('Nombre: ', nombre);
            WriteLn('Genero:', genero);
            WriteLn('Precio: ', precio:1:2);
        end;
        WriteLn;
    end;
var
    reg: novela;
begin
    while(not Eof(arch_nov)) do begin
        Read(arch_nov, reg);
        escribirNovela(reg);
    end;
end;

procedure callMenu(var arch_nov: novelas);
var
    opcion: options;
begin
    while true do begin
        WriteLn;
        WriteLn('MENU DE NOVELAS');
        WriteLn('Elija una de las siguientes opciones');
        WriteLn('1- Crear un archivo de novelas a partir de un archivo de texto');
        WriteLn('2- Agregar una novela');
        WriteLn('3- Modificar una novela');
        WriteLn('4- Listar novelas');
        WriteLn('5- Salir');
        WriteLn;

        Write('=> ');
        ReadLn(opcion);
        WriteLn;

        case opcion of
            1: crearArchivo(arch_nov);

            2: begin
                Reset(arch_nov);
                agregarNovela(arch_nov);
                Close(arch_nov);
            end;

            3: begin
                Reset(arch_nov);
                modificarNovela(arch_nov);
                Close(arch_nov);
            end;

            4: begin
                Reset(arch_nov);
                imprimir(arch_nov);
                Close(arch_nov);
            end;

            5: break

            else WriteLn('La opcion seleccionada no es valida');
        
        end;
    end;
end;

var
    archivo_novelas: novelas;
begin
    asignar(archivo_novelas);

    callMenu(archivo_novelas);
end.