
    function initDataGrid()
    {
        var _class  = " class='descriptionTabla' style='border: solid rgb(0,0,0) 0px; font-size:11px;  background-color: transparent;' ";

        loGrid.bHeaderFix = false;

        loGrid.width      = '700';
        loGrid.padding    = 5;


        if(gaDataset.length > 0)
        {

            headers  = new Array(
            // 0:  Producto
                     {text:'Producto',width:'15', hclass: 'left', bclass:'left', align:'right'},
            // 1:  Unidad de Medidda
                     {text:'UM',width:'17%', hclass: 'right', bclass: 'right', align: 'right'},
            // 2:  Cantidad Total
                     {text:'Cantidad Total', width:'17%', align: 'right'},
            // 3:  Mesa 80%
                     {text:'Mesa 80%',width:'17%', align: 'right'},
            // 4:  Camara 20%
                     {text:'C&aacute;mara 20%',width:'17%', hclass: 'right', bclass: 'right', align:'right'});


            props    = new Array(null,null,null,null,null);

            loGrid.setHeaders(headers);
            loGrid.setDataProps(props);
            loGrid.setData(gaDataset);        
            loGrid.drawInto('goDataGrid');
        }
    }


