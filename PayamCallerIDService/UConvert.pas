unit UConvert;
interface
uses
   SysUtils;
function Convert(S: String):String;
function DayConvert(S:String):String;

implementation

function Convert(S: String):String;
var
   num:int64;
   y,y1,y2,y4,y5,y7,y8,y10,y11,y13,y14,c:integer;
   sk,sk1,sk2,sk3,sk4,sk5,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15:string;
   Negative : Boolean;
begin
try
num:=strtoint64(s);
Except on EConvertError  do
      begin
         Result:='Invalid Number';
         exit;
      end;
end;


//
if num=0 then
begin
    Result:='���';
    exit;
end;

if num < 0 then
  begin
    Negative := True;
    num := ABS(num);
  end
else
   Negative := False;

c:=1;
while num>0 do
    begin

         y:=num mod 10;
         num:=num div 10;
         if c=1 then
              begin
                y1:=y;
               case y of
                    1:s1 := '��';
                    2:s1 := '��';
                    3:s1 := '��';
                    4:s1 := '����';
                    5:s1 := '���';
                    6:s1 := '��';
                    7:s1 := '���';
                    8:s1 := '���';
                    9:s1 := '��';
               else
                    s1:= '';
               end;
              end
         else if c=2 then
            begin
              y2:=y;
               case y of
                    1:s2 := '��';
                    2:s2 := '����';
                    3:s2 := '��';
                    4:s2 := '���';
                    5:s2 := '�����';
                    6:s2 := '���';
                    7:s2 := '�����';
                    8:s2 := '�����';
                    9:s2 := '���';
               else
                    s2:= '';
               end;
              end
         else if c=3 then
               case y of
                    1:s3 := '��';
                    2:s3 := '�����';
                    3:s3 := '����';
                    4:s3 := '������';
                    5:s3 := '�����';
                    6:s3 := '����';
                    7:s3 := '�����';
                    8:s3 := '�����';
                    9:s3 := '����';
               else
                    s3:= '';
               end
         else if c=4 then
              begin
               y4:=y;
               case y of
                    1:s4 := '��';
                    2:s4 := '��';
                    3:s4 := '��';
                    4:s4 := '����';
                    5:s4 := '���';
                    6:s4 := '��';
                    7:s4 := '���';
                    8:s4 := '���';
                    9:s4 := '��';
               else
                    s4:= '';
               end;
              end
         else if c=5 then
              begin
               y5:=y;
               case y of
                    1:s5 := '��';
                    2:s5 := '����';
                    3:s5 := '��';
                    4:s5 := '���';
                    5:s5 := '�����';
                    6:s5 := '���';
                    7:s5 := '�����';
                    8:s5 := '�����';
                    9:s5 := '���';
               else
                    s5:= '';
               end;
              end
         else if c=6 then
               case y of
                    1:s6 := '��';
                    2:s6 := '�����';
                    3:s6 := '����';
                    4:s6 := '������';
                    5:s6 := '�����';
                    6:s6 := '����';
                    7:s6 := '�����';
                    8:s6 := '�����';
                    9:s6 := '����';
               else
                    s6:= '';
               end
         else if c=7 then
              begin
              y7:=y;
               case y of
                    1:s7 := '��';
                    2:s7 := '��';
                    3:s7 := '��';
                    4:s7 := '����';
                    5:s7 := '���';
                    6:s7 := '��';
                    7:s7 := '���';
                    8:s7 := '���';
                    9:s7 := '��';

               else
                    s7:= '';
               end;
            end
         else if c=8 then
              begin
               y8:=y;
               case y of
                    1:s8 := '��';
                    2:s8 := '����';
                    3:s8 := '��';
                    4:s8 := '���';
                    5:s8 := '�����';
                    6:s8 := '���';
                    7:s8 := '�����';
                    8:s8 := '�����';
                    9:s8 := '���';
               else
                    s8:= '';
               end;
              end
         else if c=9 then
               case y of
                    1:s9 := '��';
                    2:s9 := '�����';
                    3:s9 := '����';
                    4:s9 := '������';
                    5:s9 := '�����';
                    6:s9 := '����';
                    7:s9 := '�����';
                    8:s9 := '�����';
                    9:s9 := '����';
               else
                    s9:= '';
              end
         else if c=10 then
              begin
              y10:=y;
               case y of
                    1:s10 := '��';
                    2:s10 := '��';
                    3:s10 := '��';
                    4:s10 := '����';
                    5:s10 := '���';
                    6:s10 := '��';
                    7:s10 := '���';
                    8:s10 := '���';
                    9:s10 := '��';

               else
                    s10:= '';
               end;
            end
         else if c=11 then
              begin
               y11:=y;
               case y of
                    1:s11 := '��';
                    2:s11 := '����';
                    3:s11 := '��';
                    4:s11 := '���';
                    5:s11 := '�����';
                    6:s11 := '���';
                    7:s11 := '�����';
                    8:s11 := '�����';
                    9:s11 := '���';
               else
                    s11:= '';
               end;
              end
         else if c=12 then
               case y of
                    1:s12 := '��';
                    2:s12 := '�����';
                    3:s12 := '����';
                    4:s12 := '������';
                    5:s12 := '�����';
                    6:s12 := '����';
                    7:s12 := '�����';
                    8:s12 := '�����';
                    9:s12:= '����';
               else
                    s12:= '';
              end
         else if c=13 then
              begin
              y13:=y;
               case y of
                    1:s13 := '��';
                    2:s13 := '��';
                    3:s13 := '��';
                    4:s13 := '����';
                    5:s13 := '���';
                    6:s13 := '��';
                    7:s13 := '���';
                    8:s13 := '���';
                    9:s13 := '��';

               else
                    s13:= '';
               end;
            end
         else if c=14 then
              begin
               y14:=y;
               case y of
                    1:s14 := '��';
                    2:s14 := '����';
                    3:s14 := '��';
                    4:s14 := '���';
                    5:s14 := '�����';
                    6:s14 := '���';
                    7:s14 := '�����';
                    8:s14 := '�����';
                    9:s14 := '���';
               else
                    s14:= '';
               end;
              end
         else if c=15 then
               case y of
                    1:s15 := '��';
                    2:s15 := '�����';
                    3:s15 := '����';
                    4:s15 := '������';
                    5:s15 := '�����';
                    6:s15 := '����';
                    7:s15 := '�����';
                    8:s15 := '�����';
                    9:s15:= '����';
               else
                    s15:= '';
              end;

    inc(c);
    end;
/////
if s1 <>''then
   sk1 := s1;
if y2=1 then
               case y1 of
                    1:sk1 := '�����';
                    2:sk1 := '������';
                    3:sk1 := '�����';
                    4:sk1 := '������';
                    5:sk1 := '������';
                    6:sk1 := '������';
                    7:sk1 := '����';
                    8:sk1 := '����';
                    9:sk1 := '�����';
               else
                    sk1:= '��';
               end
else if (s2 <>'')and (s1<>'') then
     sk1 := s2+' � '+ sk1
else if s2<>'' then
     sk1:=s2;
if (s3 <>'')and (sk1<>'') then
     sk1 := s3+' � '+ sk1
else if s3<>'' then
     sk1:=s3;
///////
if s4 <>''then
   sk2 := s4;
if y5=1 then
               case y4 of
                    1:sk2 := '�����';
                    2:sk2 := '������';
                    3:sk2 := '�����';
                    4:sk2 := '������';
                    5:sk2 := '������';
                    6:sk2 := '������';
                    7:sk2 := '����';
                    8:sk2 := '����';
                    9:sk2 := '�����';
               else
                    sk2:= '��';
               end
else if (s5 <>'')and (s4<>'') then
     sk2 := s5+' � '+ sk2
else if s5<>'' then
     sk2:=s5;
if (s6 <>'')and (sk2<>'') then
     sk2 := s6+' � '+ sk2
else if s6<>'' then
     sk2:=s6;
if (s4<>'')or(s5<>'')or(s6<>'') then
  sk2:=sk2+' ����';
////////////
if s7 <>''then
   sk3 := s7;
if y8=1 then
               case y7 of
                    1:sk3 := '�����';
                    2:sk3 := '������';
                    3:sk3 := '�����';
                    4:sk3 := '������';
                    5:sk3 := '������';
                    6:sk3 := '������';
                    7:sk3 := '����';
                    8:sk3 := '����';
                    9:sk3 := '�����';
               else
                    sk3:= '��';
               end
else if (s8 <>'')and (s7<>'') then
     sk3 := s8+' � '+ sk3
else if s8<>'' then
     sk3:=s8;
if (s9 <>'')and (sk3<>'') then
     sk3 := s9+' � '+ sk3
else if s9<>'' then
     sk3:=s9;
if (s7<>'')or(s8<>'')or(s9<>'') then
  sk3:=sk3+' ������';
/////////////
if s10 <>''then
   sk4 := s10;
if y11=1 then
               case y10 of
                    1:sk4 := '�����';
                    2:sk4 := '������';
                    3:sk4 := '�����';
                    4:sk4 := '������';
                    5:sk4 := '������';
                    6:sk4 := '������';
                    7:sk4 := '����';
                    8:sk4 := '����';
                    9:sk4 := '�����';
               else
                    sk4:= ' ��';
               end
else if (s11 <>'')and (s10<>'') then
     sk4 := s11+' � '+ sk4
else if s11<>'' then
     sk4:=s11;
if (s12 <>'')and (sk4<>'') then
     sk4 := s12+' � '+ sk4
else if s12<>'' then
     sk4:=s12;
if (s10<>'')or(s11<>'')or(s12<>'') then
  sk4:=sk4+' �������';
/////
if s13 <>''then
   sk5 := s13;
if y14=1 then
               case y13 of
                    1:sk5 := '�����';
                    2:sk5 := '������';
                    3:sk5 := '�����';
                    4:sk5 := '������';
                    5:sk5 := '������';
                    6:sk5 := '������';
                    7:sk5 := '����';
                    8:sk5 := '����';
                    9:sk5 := '�����';
               else
                    sk5:= '��';
               end
else if (s14 <>'')and (s13<>'') then
     sk5 := s14+' � '+ sk5
else if s14<>'' then
     sk5:=s14;
if (s15 <>'')and (sk5<>'') then
     sk5 := s15+' � '+ sk5
else if s15<>'' then
     sk5:=s15;
if (s13<>'')or(s14<>'')or(s15<>'') then
  sk5:=sk5+' �������';


////////////
sk:='';
if sk1 <>''then
   sk := sk1;

if (sk <>'')and (sk2<>'') then
     sk := sk2+' � '+ sk
else if sk2<>'' then
     sk:=sk2;

if (sk <>'')and (sk3<>'') then
     sk := sk3+' � '+ sk
else if sk3<>'' then
     sk:=sk3;

if (sk <>'')and (sk4<>'') then
     sk := sk4+' � '+ sk
else if sk4<>'' then
     sk:=sk4;
     
if (sk <>'')and (sk5<>'') then
     sk := sk5+' � '+ sk
else if sk5<>'' then
     sk:=sk5;
if Negative then
   Result:='���� '+sk
else
   Result:=sk
end;

function DayConvert(S:String):String;
begin
     if ((S='3')or(S='03')) then
         Result :='���'
     else if(S='23') then
         Result :='���� � ���'
     else if(S='30') then
         Result :='�� ��'
     else
         Result:=Convert(S)+'�';
end;

end.
 