program pr3_ej1;

{Si cada registro del maestro pudiera ser actualizado por 0 o 1 del detalle,
no seria necesario recorrer todo el archivo detalle. Se lee un registro
del maestro y se lo busca en el detalle hasta encontrarlo. Es decir,
si el registro se encuentra en el detalle, se recorrera el mismo hasta hallarlo.
En el peor de los casos (que no se encuentre en el detalle) se recorrera todo
el archivo.
Una vez encontrado actualizo el maestro}

type
    producto = record
        codigo: Integer;
        nombre: String[30];
        precio: Real;
        stock_actual: Integer;
        stock_minimo: Integer;
    end;

    info_producto = record
        codigo: Integer;
        ventas: Integer;
    end;

    maestro = file of producto;
    detalle = file of info_producto;

procedure actualizarMaestro(var mae: maestro; var det: detalle);
var
    reg_mae: producto;
    reg_det: info_producto;
    cantVentas: Integer;
begin
    Reset(mae);
    Reset(det);

    while(not Eof(mae)) do begin
        Read(mae, reg_mae);
                
        cantVentas := 0;
        while (not Eof(det)) do begin
            Read(det, reg_det);
            if(reg_det.codigo = reg_mae.codigo) then 
                cantVentas := cantVentas + reg_det.ventas;
        end;
        
        if(cantVentas > 0) then begin
            Seek(mae, FilePos(mae) - 1);
            reg_mae.stock_actual := reg_mae.stock_actual - cantVentas;
            Write(mae, reg_mae);
        end;
        
        Seek(det, 0);   // debo buscar desde el principio
    end;

    Close(det);
    Close(mae);
end;

var
    mae: maestro;
    det: detalle;
begin
    Assign(mae, 'productos');
    Assign(det, 'detalle_productos');

    actualizarMaestro(mae, det);
end.