{ %VERSION=1.1 }
{ %OPT=-Sew -vw }

{$MODE OBJFPC}

{ This tests that implemented abstract methods do not cause any warnings }
type
  tmyclass = class
   procedure myabstract; virtual; abstract;
  end;

  tmyclass2 = class(tmyclass)
   procedure myabstract ; override;
  end;


  procedure tmyclass2.myabstract;
   begin
   end;


var
 cla : tmyclass2;
Begin
 cla := tmyclass2.create;
end.

{
  $Log: tb0424.pp,v $
  Revision 1.2  2005/02/14 17:13:35  peter
    * truncate log

}
