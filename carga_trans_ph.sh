#!/bin/bash

psql -U postgres -d dbeyum -t -c "SELECT to_date(EXTRACT(YEAR FROM date_id) || '-' || EXTRACT(MONTH FROM date_id) || '-' || EXTRACT(DAY FROM date_id), 'YYYY-MM-dd') AS x FROM op_gt_real_sist_mng WHERE trans_real=0 ORDER BY date_id DESC" | perl -lane 'if($F[0] != "" ) { $F[0] = substr($F[0], 2,10); $F[0] =~ 's/-//g'; print $F[0];} ' | xargs -n1 /usr/bin/ph/databases/graphics/bin/carga_rsg.pl


