program pr3_ej1;
const
    valorAlto = 9999;

type
    empleado = record
        numero: Integer;
        apellido: String;
        nombre: String;
        edad: Integer;
        DNI: LongInt;
    end;

    empleados = file of empleado;

    options = 1..10;

procedure asignar(var arch_empl: empleados);
var
    path:String;
begin
    WriteLn('Ingrese el nombre o ruta del archivo: ');
    ReadLn(path);
    Assign(arch_empl, path);
end;

procedure leerEmpleado(var reg:empleado);
begin
    WriteLn('Apellido: ');
    ReadLn(reg.apellido);
    if(reg.apellido <> 'fin') then begin
        WriteLn('Nombre: ');
        ReadLn(reg.nombre);
        WriteLn('Numero: ');
        ReadLn(reg.numero);
        WriteLn('Edad: ');
        ReadLn(reg.edad);
        WriteLn('DNI: ');
        ReadLn(reg.DNI);
    end;
    WriteLn;
end;

procedure crearArchivo(var arch_empl: empleados);
var
    regEmpl: empleado;
begin
    Rewrite(arch_empl);

    leerEmpleado(regEmpl);
    while(regEmpl.apellido <> 'fin') do begin
        Write(arch_empl, regEmpl);
        leerEmpleado(regEmpl);
    end;

    Close(arch_empl);
end;

procedure imprimirEmpleado(empl:empleado);
begin
    WriteLn('Nombre: ',empl.nombre);
    WriteLn('Apellido: ',empl.apellido);
    WriteLn('Numero: ',empl.numero);
    WriteLn('Edad: ',empl.edad);
    WriteLn('DNI: ',empl.DNI);
    WriteLn;
end;

procedure listarPorNombre(var arch_empl: empleados);
var
    empLeido:String[15];
    empl:empleado;
begin
    Reset(arch_empl);

    WriteLn('Ingrese el nombre o apellido del empleado: ');
    ReadLn(empLeido);
    WriteLn;

    while(not Eof(arch_empl)) do begin
        Read(arch_empl, empl);

        if((empl.nombre = empLeido) or (empl.apellido = empLeido)) then
            imprimirEmpleado(empl);
    end;

    Close(arch_empl);
end;

procedure mostrarEmpleados(var arch_empl: empleados);
var
    regEmpl: empleado;
begin
    Reset(arch_empl);

    WriteLn('LISTA DE EMPLEADOS: ');
    
    while(not Eof(arch_empl)) do begin
        Read(arch_empl, regEmpl);
        imprimirEmpleado(regEmpl);    
    end;

    Close(arch_empl);
end;

procedure mostrarMayores70(var arch_empl: empleados);
var
    emplReg: empleado;
begin
    Reset(arch_empl);

    WriteLn('Empleados mayores de 70: ');
    
    while(not Eof(arch_empl)) do begin
        Read(arch_empl, emplReg);
        if(emplReg.edad > 70) then imprimirEmpleado(emplReg);
    end;

    Close(arch_empl);
end;

procedure existeEmpleado(var arch_empl: empleados; numEmpl: Integer; var encontrado: boolean);
var
    reg: empleado;
begin
    encontrado:= false;
    Seek(arch_empl, 0);
    while((not Eof(arch_empl)) and (not encontrado)) do begin
        Read(arch_empl, reg);
        if(reg.numero = numEmpl) then encontrado := true;
    end;
end;

procedure agregarEmpleado(var arch_empl: empleados);
var
    newEmpl: empleado;
    encontrado: boolean;
begin
    Reset(arch_empl);
    
    leerEmpleado(newEmpl);
    while(newEmpl.apellido <> 'fin') do begin
        
        existeEmpleado(arch_empl, newEmpl.numero, encontrado);
        
        if(not encontrado) then begin
            //Seek(arch_empl, FileSize(arch_empl)); Si encontrado = false -> puntero en EOF
            Write(arch_empl, newEmpl);
        end
        else begin
            WriteLn('El numero de empleado ya esta registrado');
            WriteLn;
        end;
        
        leerEmpleado(newEmpl);
    end;

    Close(arch_empl);
end;

procedure modificarEdad(var arch_empl: empleados);
var
    numLeido: Integer;
    regEmpl: empleado;
    modificado: boolean;
begin
    Reset(arch_empl);
    
    modificado:= false;

    WriteLn('Ingrese el numero del empleado a modificar su edad: ');
    ReadLn(numLeido);

    while((not Eof(arch_empl)) and (not modificado)) do begin
        Read(arch_empl, regEmpl);
        if(regEmpl.numero = numLeido) then begin
            WriteLn('Ingrese la edad: ');
            ReadLn(regEmpl.edad);
            Seek(arch_empl, FilePos(arch_empl)-1);
            Write(arch_empl, regEmpl);
            modificado:= true;
        end;
    end;

    if(not modificado) then WriteLn('El empleado no se ha encontrado');

    Close(arch_empl);
end;

procedure exportarTxt(var arch_empl: empleados; var txt_empl: Text);
var
    reg: empleado;
begin
    Assign(txt_empl, 'todos_empleados.txt');
    Rewrite(txt_empl);
    Reset(arch_empl);

    while(not Eof(arch_empl)) do begin
        Read(arch_empl, reg);
        WriteLn(txt_empl, reg.numero,' | ', reg.apellido,' | ', reg.nombre, ' | ', reg.edad,' | ', reg.DNI);
    end;

    WriteLn('Datos exportados');
    
    Close(arch_empl);
    Close(txt_empl);
end;

procedure pasarFaltaDNI(var arch_empl: empleados; var txt_sinDNI: Text);
var
    reg: empleado;
begin
    Assign(txt_sinDNI, 'faltaDNIEmpleado.txt');
    Rewrite(txt_sinDNI);
    Reset(arch_empl);

    while(not Eof(arch_empl)) do begin
        Read(arch_empl, reg);
        if(reg.DNI = 0) then
            WriteLn(txt_sinDNI, reg.numero,' | ', reg.apellido,' | ', reg.nombre, ' | ', reg.edad,' | ', reg.DNI);
    end;

    WriteLn('Empleados sin DNI exportados');
    Close(arch_empl);
    Close(txt_sinDNI);
end;

procedure leer(var arch_empl: empleados; var reg_empl: empleado);
begin
    if(not Eof(arch_empl)) then Read(arch_empl, reg_empl)
    else reg_empl.numero := valorAlto;
end;

procedure bajaEmpleado(var arch_empl: empleados);
var
    reg_empl: empleado;
    num_empl, pos_empl: Integer;
    encontrado: boolean;
begin
    Reset(arch_empl);

    Write('Ingrese el numero del empleado a borrar: ');
    ReadLn(num_empl);

    encontrado := false;

    leer(arch_empl, reg_empl);
    while(reg_empl.numero <> valorAlto) and (not encontrado) do begin
        if(reg_empl.numero = num_empl) then begin
            encontrado := true;
            pos_empl := FilePos(arch_empl) - 1;
        end;
        
        leer(arch_empl, reg_empl);
    end;

    if(encontrado) then begin
        Seek(arch_empl, FileSize(arch_empl) - 1);
        Read(arch_empl, reg_empl);
        Seek(arch_empl, pos_empl);
        Write(arch_empl, reg_empl);

        Seek(arch_empl, FileSize(arch_empl) - 1);
        Truncate(arch_empl);
        
        WriteLn('Baja de empleado finalizada.');
    end
    else WriteLn('El empleado no se encuentra en el archivo.');

    Close(arch_empl);
end;

procedure callMenu(var arch_empl: empleados; var txt_empl: Text; var txt_sinDNI: Text);
    procedure printMenu();
    begin
        WriteLn;
        WriteLn('MENU DE EMPLEADOS');
        WriteLn('ELIJA UNA DE LAS SIGUIENTES OPCIONES: ');
        WriteLn('1- Crear archivo de empleados');
        WriteLn('2- Listar en pantalla empleados segun nombre o apellido');
        WriteLn('3- Listar todos los empleados');
        WriteLn('4- Listar empleados mayores de 70');
        WriteLn('5- Agregar empleado/s');
        WriteLn('6- Modificar edad empleado');
        WriteLn('7- Exportar empleados a texto');
        WriteLn('8- Exportar empleados sin DNI a texto');
        WriteLn('9- Borrar empleado');
        WriteLn('10- Salir');
        WriteLn;
    end;
var
    opcion:options;
begin
    printMenu;
    
    Write('=> ');
    ReadLn(opcion);
    WriteLn;

    while(opcion <> 10) do begin

        case opcion of
            1: crearArchivo(arch_empl);
            
            2: listarPorNombre(arch_empl);
            
            3: mostrarEmpleados(arch_empl);
            
            4: mostrarMayores70(arch_empl);
            
            5: agregarEmpleado(arch_empl);
            
            6: modificarEdad(arch_empl);
            
            7: exportarTxt(arch_empl, txt_empl);
            
            8: pasarFaltaDNI(arch_empl, txt_sinDNI);
            
            9: bajaEmpleado(arch_empl); 
        
            else WriteLn('La opcion seleccionada no es valida');
        end;
    
        printMenu;

        Write('=> ');
        ReadLn(opcion);
        WriteLn;
    end;
end;

var
    archivo: empleados;
    empleados_texto: Text;
    empleadosFaltaDNI: Text;
begin
    asignar(archivo);

    callMenu(archivo, empleados_texto, empleadosFaltaDNI);
end.