program pr1_ej5;
const
    nombretxt = 'celulares.txt';
    SinStocktxt = 'SinStock.txt';
type
    celular = record
        codigo: Integer;
        nombre: String[20];
        descripcion: String;
        marca: String[15];
        precio: Real;
        minStock: Integer;
        disStock: Integer;
    end;

    celulares = file of celular;

    options = 1..9;

procedure asignar(var arch_cel: celulares);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo: ');
    ReadLn(path);
    Assign(arch_cel, path);
end;

procedure crearArchivo(var arch_cel: celulares);
    procedure leerTxt(var arch: celulares; var base: Text; var reg: celular);
    begin
        with reg do begin
            ReadLn(base, codigo, precio, marca);
            ReadLn(base, disStock, minStock, descripcion);
            ReadLn(base, nombre);
        end;
    end;
var
    archivo_base: Text;
    regCel: celular;
begin
    Assign(archivo_base, nombretxt);
    Reset(archivo_base);

    Rewrite(arch_cel);

    WriteLn('Creando archivo de celulares...');

    while(not Eof(archivo_base)) do begin
        leerTxt(arch_cel, archivo_base, regCel);
        Write(arch_cel, regCel);
    end;

    WriteLn('Archivo de celulares creado');

    Close(arch_cel);

    Close(archivo_base);
end;

procedure imprimirCelular(cel: celular);
begin
    with cel do begin
        WriteLn('Codigo: ', codigo);
        WriteLn('Nombre: ', nombre);
        WriteLn('Descripcion:', descripcion);
        WriteLn('Marca: ', marca);
        WriteLn('Precio: ', precio:1:2);
        WriteLn('Stock disponible: ', disStock);
        WriteLn('Stock minimo: ', minStock);
    end;
    WriteLn;
end;

procedure listarCelularesBajoStock(var arch_cel: celulares);
var
    regCel: celular;
begin
    WriteLn('Celulares con stock por debajo del minimo: ');

    while(not Eof(arch_cel)) do begin
        Read(arch_cel, regCel);
        if(regCel.disStock < regCel.minStock) then imprimirCelular(regCel);
    end;
end;

procedure listarPorDescripcion(var arch_cel: celulares);
var
    regCel: celular;
    strBuscado: String;
begin
    WriteLn('Ingrese una palabra clave de la descripcion buscada: ');
    ReadLn(strBuscado);

    while(not Eof(arch_cel)) do begin
        Read(arch_cel, regCel);
        if(Pos(strBuscado, regCel.descripcion) > 0) then imprimirCelular(regCel);
    end;

end;

procedure escribirTxt(var arch_txt: Text; reg: celular);
begin
    with reg do begin
            WriteLn(arch_txt, codigo, ' ', precio, ' ', marca);
            WriteLn(arch_txt, disStock, ' ', minStock, ' ', descripcion);
            WriteLn(arch_txt, nombre);
    end;
end;

procedure exportarTxt(var arch_cel: celulares);
var
    arch_txt: Text;
    regCel: celular;
begin
    Assign(arch_txt, nombretxt);
    Rewrite(arch_txt);

    while(not Eof(arch_cel)) do begin
        Read(arch_cel, regCel);
        escribirTxt(arch_txt, regCel);
    end;

    Close(arch_txt);

    WriteLn('Exportacion finalizada');
    WriteLn;
end;

procedure imprimir(var arch_cel: celulares);
var
    reg: celular;
begin
    while(not Eof(arch_cel)) do begin
        Read(arch_cel, reg);
        imprimirCelular(reg);
    end;
end;

procedure agregarCelular(var arch_cel: celulares);
    procedure leerCelular(var reg: celular);
    begin
        with reg do begin
            Write('Codigo: '); ReadLn(codigo);
            
            if(codigo <> 0) then begin
                Write('Nombre: '); ReadLn(nombre);
                Write('Descripcion: '); ReadLn(descripcion);
                Write('Marca: '); ReadLn(marca);
                Write('Precio: '); ReadLn(precio);
                Write('Stock minimo: '); ReadLn(minStock);
                Write('Stock disponible: '); ReadLn(disStock);
            end;
            
            WriteLn;
        end;
    end;
    procedure celularExiste(var arch_cel:celulares; nomCel:String; var encontrado:boolean);
    var
        reg: celular;
    begin
        encontrado := false;
        Seek(arch_cel, 0);

        while((not Eof(arch_cel)) and (not encontrado)) do begin
            Read(arch_cel, reg);
            if(reg.nombre = nomCel) then encontrado := true;
        end;
    end;
var
    regCel: celular;
    encontrado: boolean;
begin
    WriteLn('Ingreso de datos de celular/es');

    leerCelular(regCel);
    while(regCel.codigo <> 0) do begin

        celularExiste(arch_cel, regCel.nombre, encontrado);

        if(not encontrado) then begin
            //Seek(arch_cel, FileSize(arch_cel)); Si encontro = false significa que puntero está en EOF
            Write(arch_cel, regCel);
        end
        else WriteLn('El celular ya esta registrado');
        
        leerCelular(regCel);
    end;

    WriteLn;
    WriteLn('Carga de celular/es finalizada');
end;

procedure modificarStock(var arch_cel: celulares);
var
    regCel: celular;
    nombreLeido: String[20];
    modificado: boolean;
begin
    modificado:= false;

    WriteLn('Ingrese el nombre del celular a modificar su stock: ');
    ReadLn(nombreLeido);

    while((not Eof(arch_cel)) and (not modificado)) do begin
        Read(arch_cel, regCel);
        
        if(regCel.nombre = nombreLeido) then begin
            WriteLn('Ingrese la cantidad de stock: ');
            ReadLn(regCel.disStock);
            Seek(arch_cel, FilePos(arch_cel)-1);
            Write(arch_cel, regCel);
            modificado := true; 
        end;

    end;

    if(not modificado) then WriteLn('El celular no se ha encontrado');
end;

procedure exportarSinStock(var arch_cel: celulares);
var
    regCel: celular;
    arch_txt: Text;
begin
    Assign(arch_txt, SinStocktxt);
    Rewrite(arch_txt);

    while(not Eof(arch_cel)) do begin
        Read(arch_cel, regCel);
        if(regCel.disStock = 0) then escribirTxt(arch_txt, regCel);
    end;

    WriteLn('Exportacion de celulares sin stock finalizada');

    Close(arch_txt);
end;

procedure callMenu(var archivo_celulares: celulares);
var
    opcion: options;
begin
    while true do begin    
        WriteLn;
        WriteLn('MENU DE CELULARES');
        WriteLn('Elija una de las opciones a continuacion');
        WriteLn('1- Crear archivo de celulares a partir de archivo de texto');
        WriteLn('2- Listar en pantalla celulares con stock menor al minimo');
        WriteLn('3- Listar en pantalla celulares segun descripcion proporcionada');
        WriteLn('4- Exportar archivo de celulares a archivo de texto');
        WriteLn('5- Agregar celular/es a la lista');
        WriteLn('6- Modificar stock de celular');
        WriteLn('7- Exportar a texto celulares sin stock');
        WriteLn('8- Listar todos los celulares');
        WriteLn('9- Salir');
        WriteLn;
        WriteLn;
    
        Write('=> ');
        ReadLn(opcion);
        WriteLn;

        case opcion of
            
            1: crearArchivo(archivo_celulares);

            2: begin
                Reset(archivo_celulares);
                listarCelularesBajoStock(archivo_celulares);
                Close(archivo_celulares);
            end;

            3: begin
                Reset(archivo_celulares);
                listarPorDescripcion(archivo_celulares);
                Close(archivo_celulares);
            end;

            4: begin
                Reset(archivo_celulares);
                exportarTxt(archivo_celulares);
                Close(archivo_celulares);
            end;
            
            5: begin
                Reset(archivo_celulares);
                agregarCelular(archivo_celulares);
                Close(archivo_celulares);
            end;

            6: begin
                Reset(archivo_celulares);
                modificarStock(archivo_celulares);
                Close(archivo_celulares);
            end;

            7: begin
                Reset(archivo_celulares);
                exportarSinStock(archivo_celulares);
                Close(archivo_celulares);
            end;

            8: begin
                Reset(archivo_celulares);
                imprimir(archivo_celulares);
                Close(archivo_celulares);
            end;

            9: break

            else WriteLn('La opcion ingresada no es valida');

        end;
    end;
end;

var
    archivo_celulares: celulares;
begin
    asignar(archivo_celulares);

    callMenu(archivo_celulares);
end.