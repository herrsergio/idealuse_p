#!/usr/bin/perl 
##########################################################################################################
# Nombre Archivo  : carga_rsg.pl
# Compa�a        : Yum Brands Intl
# Autor           : Sandra Castro P. 
# Objetivo        : Carga los datos del archivo real-sistema_gerente.txt en la BD.
# Fecha Creacion  : 24/Oct/2005
# Inc/requires    :
# Modificaciones  :Mario Ch. A.   Puede recibir como argumento una fecha o no
#                                 en caso de no ser necesario toda el d�a
#                                 actual tiene modificaciones para PH 
# Fecha  yy-mm-dd Programador     Observaciones
##########################################################################################################
BEGIN
{
open (STDERR, ">/usr/bin/ph/databases/graphics/log/carga_rsg.err");
}
# Invcluyendo los paquetes que se utilizarán
use lib "/usr/bin/ph/databases/graphics/lib";
use gtConnect;

#Inicialización de valriables
$archivo_log="/usr/bin/ph/databases/graphics/log/carga_rsg.log";
$file_target="/usr/bin/ph/tables/real_sistema_gerente.txt";
$FILE="/usr/bin/ph/tables/real_sistema_gerente.txt";

$ENV{PATH} .= ":/usr/bin/ph";

if($ARGV[0] ne "") {
    chomp($ARGV[0]);
    $todayoformato=$ARGV[0];
    $yy = substr($todayoformato, 0, 2);
    $mm = substr($todayoformato, 2, 2);
    $dd = substr($todayoformato, 4, 6);
    $today = $yy."-".$mm."-".$dd;
} else {
    $today=qx/date '+%y-%m-%d'/;
    chop($today);
    $todayoformato=qx/date '+%y%m%d'/;
    chop($todayoformato);
}

$phpqdate = qx/\/usr\/bin\/ph\/sysshell.new SUS > \/dev\/null 2>&1; \/usr\/fms\/op\/bin\/phpqdate/;
$hace7dias=qx/\/usr\/bin\/ph\/sysshell.new SUS > \/dev\/null 2>&1; \/usr\/bin\/ph\/dant.s $today 7/;
chomp($hace7dias);

# Sentencia para insertar en la tabla los valores
# date_id, ppt_real, ppt_sist, ppt_mng, trans_real, trans_sist, trans_mng
$InsertRSG=<<EOF;
	INSERT INTO op_gt_real_sist_mng  VALUES (?,?,?,?,?,?,?)
EOF
# Sentencia para actualizar los valores en la tabla
$UpdateRSG=<<EOF;
	UPDATE op_gt_real_sist_mng set ppt_real=?, ppt_sist=?, ppt_mng=?, trans_real=?, trans_sist=?, trans_mng=? where date_id=?
EOF

open(LOG,">$archivo_log") or die("No pude abrir $archivo_log: $!\n");
# Si la fecha de hoy es igual a la fecha de negocio entonces hay que regenerar la información de ventas en print1
if($todayoformato == $phpqdate){
	print LOG "Regenerando datos de la fecha de hoy $today\n";
	system (". /usr/bin/ph/sysshell.new SUS > /dev/null 2>&1; /usr/fms/op/bin/phzap phpqpr 01 1 3 | /usr/bin/compress - > /usr/fms/op/rpts/print1/$today.Z");
	system ("/usr/fms/op/bin/phzap chmod 0777 /usr/fms/op/rpts/print1/$today.Z");
	system ("/usr/bin/ph/txthistory/wrapgen.pl 0 > /dev/null");
}

print LOG "- Determinando si la fecha de hoy existe en real_sistema_gerente.txt\n";
$reg_aux = qx/grep \"^$today\" $file_target/;
if($reg_aux eq ""){
	$flag_file=0;
}else{
	$flag_file=1;
}
print LOG "\t\tflag_file= $flag_file\n\n";
print LOG "- Calculamos los valores nuevos que debemos actualizar y/o insertar,\n";
$items_calculados=calcula_valores($today, $flag_file);
print LOG "\t\t$items_calculados\n\n";
print LOG "- Si flag_file es igual a cero, se insertan los valores nuevos en el archivo,\n  si no solo se actualizan\n";
opera_sobre_archivo($today, $flag_file, $items_calculados);

print LOG "*******************************************\n";
print LOG "- Leyendo archivo real_sistema_gerente.txt\n";
@regs = get_rsg_Data();

foreach $valor (@regs) {
	@datafields=split(/\|/,$valor);
	@ymd=split(/\-/,$datafields[0]);
	$date_id_ori=$datafields[0];
	$year="20$ymd[0]";
	$date_id="$year-$ymd[1]-$ymd[2]";
	$ppt_real=$datafields[1];
	$ppt_sist=$datafields[2];
	$ppt_gte=$datafields[3];
	$trz_real=$datafields[4];
	$trz_sist=$datafields[5];
	$trz_gte=$datafields[6];
	#$trans_real = round($ppt_real?$trz_real*9/$ppt_real:0);
	$trans_real = $trz_real;
	#$trans_sist = round($ppt_sist?$trz_sist*9/$ppt_sist:0);
	$trans_sist = $trz_sist;
	#$trans_gte = round($ppt_gte?$trz_gte*9/$ppt_gte:0);
	$trans_gte = $trz_gte;
	$flagExistReg = existsReg($date_id);
	$diffdays = diffDays($date_id_ori, $hace7dias);
 	if($flagExistReg==1){
		if($diffdays<=0){
			$sth=$dbh->prepare($UpdateRSG);
			if($sth->execute($ppt_real,$ppt_sist, $ppt_gte,$trans_real, $trans_sist,$trans_gte,$date_id)){
				print LOG "- Actualizo registro: $date_id_ori\n";
			}else{
				print LOG " - Error al actualizar registro : $date_id_ori\n";
			}
		}
	}else{
			$sth=$dbh->prepare($InsertRSG);
			if ($sth->execute($date_id,$ppt_real,$ppt_sist, $ppt_gte,$trans_real, $trans_sist,$trans_gte)){
				print LOG "- Inserto registro  : $date_id_ori\n";
			}else{
				print LOG " - Error al insertar registro : $date_id_ori\n";
			}
	}
}
print LOG "*******************************************\n";
close(LOG);

sub get_rsg_Data {
   local @linea=();
   $i=0;   #Contadores para los arreglos formados para insertar en cada tabla
   open(FILE) or die "Error: no se encuentra $FILE\n";
   while ($line=<FILE>) {
        $linea[$i++] = "$line";
   }
   close(FILE);
   return(@linea);
}

sub existsReg {
   my $date_idt = shift @_;
   local $get_register = $dbh->prepare("SELECT COUNT(*) FROM op_gt_real_sist_mng WHERE date_id = ?");

   $get_register->execute($date_idt);
   if($get_register ->rows == 0){
      return (0);
   } else {
     $regs = $get_register->fetchrow();
      if ( $regs == 0 ) {
         return(0);
       } else {
         return(1);
       }
   }
}

sub diffDays {
	my $date_target = shift @_;
	my $hace1sem = shift @_;
	local $getDiffDays = $dbh->prepare("SELECT to_date(?,'yy-mm-dd')- to_date(?,'yy-mm-dd') as daysdiff");
	$getDiffDays->execute($hace1sem,$date_target);
	if( $regptr =  $getDiffDays->fetchrow_hashref() ){
			$daysdiff = $regptr->{"daysdiff"};
	}
	return($daysdiff);
}

sub calcula_valores{
	my $todayl = shift @_;
	my $flag_fileloc = shift @_;
	@ymdtoday=split(/\-/,$todayl);
	$fecha_fms = @ymdtoday[1]."/".@ymdtoday[2]."/".@ymdtoday[0]; #mes/dia/anyo
	#@output = qx/\/home\/httpd\/html\/php\/hpedidos\/loadFMS.s $fecha_fms $fecha_fms/;
	@output = qx/\. \/usr\/bin\/ph\/sysshell.new FMS \> \/dev\/null 2\>&1;fcpgchis $fecha_fms $fecha_fms/;
	#$ppt_real_c=qx/\/usr\/bin\/ph\/txthistory\/ppt-real.pl --fecha $todayl --nocache --calc/;
	$ppt_real_c = 0;
	#$ppt_sist_c = qx/\/usr\/bin\/ph\/txthistory\/ppt-pron.pl --fecha $todayl --nocache --calc --natural/;
	$ppt_sist_c = 0;
	$ppt_gte_c = 0;
	#if($flagfileloc == 0){
		#$ppt_gte_c=$ppt_sist_c;
	#}else{
		#$ppt_gte_c = qx/\/usr\/bin\/ph\/txthistory\/ppt-gerente.pl --fecha $todayI/;
	#}
    foreach my $reg (@output){
		if($reg =~ /(Real)/){
			$reg=~s/\s+/:/g;
			@real=split(/:/,$reg);
            if($#real eq 8){
                $com=4;
                $cen=7;
            }else{
                $com=5;
                $cen=9;
            }
			$trans_real = $real[$com] + $real[$cen];
		}
		if($reg =~ /(Sistem)/){
			$reg=~s/\s+/:/g;
			@sist=split(/:/,$reg);
            if($#sist eq 7){
                $com=3;
                $cen=6;
            }else{
                $com=4;
                $cen=8;
            }
			$trans_sist = $sist[$com] + $sist[$cen];
		}
		if($reg =~ /(Gerente)/){
            $reg=~s/[a-z,A-Z]//g;
			$reg=~s/\s+/:/g;
			@mng=split(/:/,$reg);
            if($#mng eq 7){
                $com=3;
                $cen=6;
            }else{
                $com=4;
                $cen=8;
            }
			$trans_gte = $mng[$com] + $mng[$cen];
		}
	}
	$valores_calc="$ppt_real_c|$ppt_sist_c|$ppt_gte_c|$trans_real|$trans_sist|$trans_gte|";
	return($valores_calc);
}

sub opera_sobre_archivo{
	my $todaynew = shift @_;
	my $flag_fileloc = shift @_;
	my $reg_new_bd = shift @_;
	@reg_new_file=split(/\|/,$reg_new_bd);
	#$cbz_real = $reg_new_file[0]*$reg_new_file[3]/9;
	$tr_real = $reg_new_file[3];
	#$cbz_sist = $reg_new_file[1]*$reg_new_file[4]/9;
	$tr_sist = $reg_new_file[4];
	#$cbz_gte = $reg_new_file[2]*$reg_new_file[5]/9;
	$tr_gte = $reg_new_file[5];
	$new_reg_file = "$reg_new_file[0]|$reg_new_file[1]|$reg_new_file[2]|$tr_real|$tr_sist|$tr_gte|";
	if($flag_fileloc == 0){
		print LOG "         Se inserta el valor en el archivo $file_target\n";
		open(TARGET,">>$file_target") or die("No pude abrir: $file_target!\n");
		print TARGET "$todaynew|$new_reg_file";
		close(TARGET);
		system("cat $file_target| sort -r > /tmp/este.txt");
	}else{
		print LOG "         Se actualiza el valor en el archivo $file_target\n";
		$file_temp = "/tmp/borrame.txt";
		system("grep -v \"^$today\" $file_target > $file_temp");
		open(ACT,">>$file_temp") or die("No pude abrir: $file_temp!\n");
		print ACT "$todaynew|$new_reg_file";
		close(ACT);
		system("cat $file_temp | sort -r > /tmp/este.txt");
		system("rm $file_temp");
	}
	system("/usr/fms/op/bin/phzap mv /tmp/este.txt $file_target");
	system("/usr/fms/op/bin/phzap chmod 666 $file_target");
}
sub round {
    my($number) = shift;
    return int($number + .5);
}
1;
