
<%!
    String getDataset(String msWeek, String msYear, String msPeriod, String msWeekId, String msDay)
    {
        String lsQuery;
	String products     = getProducts("/usr/local/tomcat/webapps/ROOT/Planning/IdealUse/Rpt/Products2Display.conf");
	String selectedDate = getDate(msWeek, msYear, msPeriod, msDay);
	String TransManager = getTransManager(selectedDate);
	String goalDate     = getLastDateEqualRealTransactions(TransManager);

	float carneResTotal    = 0.0f;
	float carnePuercoTotal = 0.0f;
	float carneMixta       = 0.0f;

	float verdurasMixta   = 0.0f;
	float pimientoTotal   = 0.0f;
	float cebollaTotal    = 0.0f;
	float champinonTotal  = 0.0f;
        float tempVerdura     = 0.0f;
	
	//System.out.println("goalDate = "+goalDate);

        lsQuery = "SELECT ideal_use FROM op_inv_ideal_use "+
	          "WHERE "+
		  "turn_date='"+goalDate+"' AND inv_id IN ('10005') ";
        String mstotalIdealUseRes = moAbcUtils.queryToString(lsQuery);	
	float totalIdealUseRes = new Float (mstotalIdealUseRes);

	//System.out.println("totalIdealUseRes = "+totalIdealUseRes);

        lsQuery = "SELECT ideal_use FROM op_inv_ideal_use "+
	          "WHERE "+
		  "turn_date='"+goalDate+"' AND inv_id IN ('10057') ";
        String mstotalIdealUsePuerco = moAbcUtils.queryToString(lsQuery);	
	float  totalIdealUsePuerco  = new Float (mstotalIdealUsePuerco);

	//System.out.println("totalIdealUsePuerco = "+totalIdealUsePuerco);

        if ( totalIdealUseRes > totalIdealUsePuerco ) {
	    float difRes = totalIdealUseRes - totalIdealUsePuerco;
	    carneMixta = Math.round(2.0f * totalIdealUsePuerco * 0.7f * 100.0f)/100.0f; 
            carneResTotal = ( totalIdealUsePuerco * 0.3f ) + difRes;
	    carneResTotal = Math.round(carneResTotal*100.0f)/100.0f;
	    carnePuercoTotal = Math.round(totalIdealUsePuerco * 0.3f * 100.0f)/100.0f;
	    //System.out.println("Res > Puerco");
	    //System.out.println("carneMixta: "+carneMixta);
	    //System.out.println("carneResTotal: "+carneResTotal);
	    //System.out.println("carnePuercoTotal: "+carnePuercoTotal);
	} else {
	    float difPuerco = totalIdealUsePuerco - totalIdealUseRes;
	    carneMixta = Math.round(2.0f * totalIdealUseRes * 0.7f*100.0f)/100.0f; 
            carnePuercoTotal = ( totalIdealUseRes * 0.3f ) + difPuerco;
	    carnePuercoTotal = Math.round(carnePuercoTotal*100.0f)/100.0f;
	    carneResTotal = Math.round(totalIdealUseRes * 0.3f*100.0f)/100.0f;
	    //System.out.println("Res < Puerco");
	    //System.out.println("carneMixta: "+carneMixta);
	    //System.out.println("carneResTotal: "+carneResTotal);
	    //System.out.println("carnePuercoTotal: "+carnePuercoTotal);
	}

        lsQuery = "SELECT ideal_use FROM op_inv_ideal_use "+
	          "WHERE "+
		  "turn_date='"+goalDate+"' AND inv_id IN ('10041') ";
        String mstotalIdealUsePimiento  = moAbcUtils.queryToString(lsQuery);	
	float totalIdealUsePimiento  = new Float (mstotalIdealUsePimiento);

	//System.out.println("totalIdealUsePimiento = "+totalIdealUsePimiento);

        lsQuery = "SELECT ideal_use FROM op_inv_ideal_use "+
	          "WHERE "+
		  "turn_date='"+goalDate+"' AND inv_id IN ('10053') ";
        String mstotalIdealUseCebolla = moAbcUtils.queryToString(lsQuery);	
	float totalIdealUseCebolla    = new Float (mstotalIdealUseCebolla);

	//System.out.println("totalIdealUseCebolla = "+totalIdealUseCebolla);

        lsQuery = "SELECT ideal_use FROM op_inv_ideal_use "+
	          "WHERE "+
		  "turn_date='"+goalDate+"' AND inv_id IN ('10050') ";
        String mstotalIdealUseChampinon = moAbcUtils.queryToString(lsQuery);	
	float totalIdealUseChampinon    = new Float (mstotalIdealUseChampinon);

	//System.out.println("totalIdealUseChampinon = "+totalIdealUseChampinon);
 
	float[] usosVerduras = new float[3];

	usosVerduras[0] = totalIdealUseChampinon;
	usosVerduras[1] = totalIdealUsePimiento;
	usosVerduras[2] = totalIdealUseCebolla;

	Arrays.sort(usosVerduras);

        tempVerdura    = Math.round(usosVerduras[0] * 0.6f * 100.0f)/100.0f;
        verdurasMixta  = 3.0f * tempVerdura;
	pimientoTotal  = Math.round((totalIdealUsePimiento - tempVerdura)*100.0f)/100.0f;
	cebollaTotal   = Math.round((totalIdealUseCebolla - tempVerdura)*100.0f)/100.0f;
	champinonTotal = Math.round((totalIdealUseChampinon - tempVerdura)*100.0f)/100.0f;

	//System.out.println("verdurasMixta = "+verdurasMixta);
	//System.out.println("cebollaTotal = "+cebollaTotal);
	//System.out.println("pimientoTotal= "+pimientoTotal);
	//System.out.println("champinonTotal= "+champinonTotal);
        
        lsQuery = "(SELECT d.inv_desc, d.inv_unit_measure, i.ideal_use, i.ideal_use*0.8, i.ideal_use*0.2  FROM op_inv_ideal_use as i INNER JOIN "+
	          "op_grl_cat_inventory as d ON i.inv_id=d.inv_id WHERE "+
		  "i.turn_date='"+goalDate+"' AND i.inv_id IN ("+products+") "+
		  "UNION "+
		  "SELECT d.inv_desc, d.inv_unit_measure, '"+carneResTotal+"', '"+carneResTotal+"'*0.8, '"+carneResTotal+"'*0.2 FROM op_inv_ideal_use "+
		  "as i INNER JOIN op_grl_cat_inventory as d ON i.inv_id=d.inv_id WHERE "+
		  "i.turn_date='"+goalDate+"' AND i.inv_id IN ('10005') "+
		  "UNION "+
		  "SELECT d.inv_desc, d.inv_unit_measure, '"+carnePuercoTotal+"', '"+carnePuercoTotal+"'*0.8, '"+carnePuercoTotal+"'*0.2 FROM "+
		  " op_inv_ideal_use as i INNER JOIN "+
		  "op_grl_cat_inventory as d ON i.inv_id=d.inv_id WHERE "+
		  "i.turn_date='"+goalDate+"' AND i.inv_id IN ('10057') " +
		  "UNION "+
		  "SELECT 'CARNE MIXTA', 'KILO', '"+carneMixta+"', '"+carneMixta+"'*0.8, '"+carneMixta+"'*0.2 "+ 
		  "UNION "+
		  "SELECT d.inv_desc, d.inv_unit_measure, '"+pimientoTotal+"', '"+pimientoTotal+"'*0.8, '"+pimientoTotal+"'*0.2 FROM "+
		  " op_inv_ideal_use as i INNER JOIN "+
		  "op_grl_cat_inventory as d ON i.inv_id=d.inv_id WHERE "+
		  "i.turn_date='"+goalDate+"' AND i.inv_id IN ('10041') " +
		  "UNION "+
		  "SELECT d.inv_desc, d.inv_unit_measure, '"+cebollaTotal+"', '"+cebollaTotal+"'*0.8, '"+cebollaTotal+"'*0.2 FROM "+
		  " op_inv_ideal_use as i INNER JOIN "+
		  "op_grl_cat_inventory as d ON i.inv_id=d.inv_id WHERE "+
		  "i.turn_date='"+goalDate+"' AND i.inv_id IN ('10053') " +
		  "UNION "+
		  "SELECT d.inv_desc, d.inv_unit_measure, '"+champinonTotal+"', '"+champinonTotal+"'*0.8, '"+champinonTotal+"'*0.2 FROM "+
		  " op_inv_ideal_use as i INNER JOIN "+
		  "op_grl_cat_inventory as d ON i.inv_id=d.inv_id WHERE "+
		  "i.turn_date='"+goalDate+"' AND i.inv_id IN ('10050') " +
		  "UNION "+
		  "SELECT 'VERDURA MIXTA', 'KILO', '"+verdurasMixta+"', '"+verdurasMixta+"'*0.8, '"+verdurasMixta+"'*0.2 ) order by 1";
		   


        return moAbcUtils.getJSResultSet(lsQuery);
    }

    String getProducts(String Filename)
    {
        File file = new File (Filename); 
	String products="";
	try {
	    Scanner scanner = new Scanner (file);
	    while (scanner.hasNextLine ()) {
	        String line = scanner.nextLine ();
		String newline = ignoreComments (line);
		if (newline != null) {
		    //System.out.println (newline);
		    products = products + ",'"+newline+"'";
		}
	    }
	    products = products.substring(1, products.length());
	} catch (FileNotFoundException e) {
	    e.printStackTrace ();
	}

	return products;
    }

    String ignoreComments (String line) {
        String result_line = null;
	int upto = line.indexOf ('#');
	if (upto != 0 && upto > 0) {
	    result_line = line.substring (0, upto);
	} else if (upto < 0) {
	    result_line = line;
	}
	return result_line;
    }
    

    String getLastDateEqualRealTransactions(String msTrans)
    {
        /*
        String lsQuery = "SELECT to_date(EXTRACT(YEAR FROM date_id) || '-' "+ 
	                 "|| EXTRACT(MONTH FROM date_id) || '-' "+
			 "|| EXTRACT(DAY FROM date_id), 'YYYY-MM-dd') AS x "+
			 "FROM op_gt_real_sist_mng WHERE trans_real="+msTrans+" ORDER BY x DESC LIMIT 1";
        */

        String lsQuery = "SELECT to_date(EXTRACT(YEAR FROM date_id) || '-' "+
                         "|| EXTRACT(MONTH FROM date_id) || '-' "+
                         "|| EXTRACT(DAY FROM date_id), 'YYYY-MM-dd') AS x "+
                         "FROM op_gt_real_sist_mng "+
                         "WHERE trans_real="+msTrans+" "+
                         "OR (trans_real BETWEEN "+msTrans+"-10  AND "+msTrans+"+10) ORDER BY x DESC";        

	String Result = moAbcUtils.queryToString(lsQuery);

	if(Result.equals("")) {
	    lsQuery = "SELECT to_date(EXTRACT(YEAR FROM date_id) || '-' "+
	              "|| EXTRACT(MONTH FROM date_id) || '-' "+
		      "|| EXTRACT(DAY FROM date_id), 'YYYY-MM-dd') AS x "+
		      "FROM op_gt_real_sist_mng "+
                      "WHERE trans_real BETWEEN " +msTrans+"-15 AND "+msTrans+"+15 ORDER BY x DESC"; 
            Result = moAbcUtils.queryToString(lsQuery);
	}

	return Result;
    }

    String getTransManager(String msDate)
    {
        String lsQuery = "SELECT trans_mng  from op_gt_real_sist_mng where date_id='"+msDate+"'";

	String yymmdd  = msDate.substring(2, 4)+msDate.substring(5,7)+msDate.substring(8,10);

	try {
	    Process p = Runtime.getRuntime().exec("/usr/bin/ph/databases/graphics/bin/carga_rsg.pl "+yymmdd);
            p.waitFor();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException ie) {
            ie.printStackTrace();
        }


	return moAbcUtils.queryToString(lsQuery);
    }

    String getDate(String msWeek, String msYear, String msPeriod, String msDay)
    {
        String lsQuery;

	lsQuery = "SELECT to_char(date_id, 'YYYY-MM-DD') AS begindate " +
	          "FROM ss_cat_time WHERE year_no="+msYear+" AND period_no="+msPeriod+" AND "+
		  "week_no="+msWeek+" AND weekday_id IN (SELECT weekday_id FROM ss_cat_time "+
		  "WHERE year_no="+msYear+" AND period_no="+msPeriod+" AND "+
		  "week_no="+msWeek+" AND EXTRACT(day FROM date_id) = " + msDay + ")";

	return moAbcUtils.queryToString(lsQuery);
    }

%>
