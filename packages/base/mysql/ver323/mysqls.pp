program mysqls;

uses mysql,mysql_com;


begin
  Writeln('PASCAL');
  Writeln ('MYSQL : ',sizeof(TMYSQL),' options : ',sizeof(st_mysql_options));
  writeln ('MYSQL_DATA : ',sizeof(TMYSQL_DATA));
  writeln ('MYSQL_ROWS : ',sizeof(TMYSQL_ROWS));
  writeln ('MYSQL_ROW : ',sizeof(TMYSQL_ROW));
  writeln ('MYSQL_FIELD : ',sizeof(TMYSQL_FIELD));
  writeln ('MYSQL_RES : ',sizeof(TMYSQL_RES));
  writeln ('MEM_ROOT : ',sizeof(TMEM_ROOT));
  writeln ('my_bool : ',sizeof(my_bool));
  writeln ('TNET : ',sizeof(TNET),' TNET.nettype : ',SizeOf(net_type));
  writeln ('USED_MEM : ',sizeof(TUSED_MEM));
end.
  $Log: mysqls.pp,v $
  Revision 1.2  2005/02/14 17:13:19  peter
    * truncate log

}
