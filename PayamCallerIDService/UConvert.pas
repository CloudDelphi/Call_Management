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
    Result:='’›—';
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
                    1:s1 := 'Ìﬂ';
                    2:s1 := 'œÊ';
                    3:s1 := '”Â';
                    4:s1 := 'çÂ«—';
                    5:s1 := 'Å‰Ã';
                    6:s1 := '‘‘';
                    7:s1 := 'Â› ';
                    8:s1 := 'Â‘ ';
                    9:s1 := '‰Â';
               else
                    s1:= '';
               end;
              end
         else if c=2 then
            begin
              y2:=y;
               case y of
                    1:s2 := 'œÂ';
                    2:s2 := '»Ì” ';
                    3:s2 := '”Ì';
                    4:s2 := 'çÂ·';
                    5:s2 := 'Å‰Ã«Â';
                    6:s2 := '‘’ ';
                    7:s2 := 'Â› «œ';
                    8:s2 := 'Â‘ «œ';
                    9:s2 := '‰Êœ';
               else
                    s2:= '';
               end;
              end
         else if c=3 then
               case y of
                    1:s3 := '’œ';
                    2:s3 := 'œÊÌ” ';
                    3:s3 := '”Ì’œ';
                    4:s3 := 'çÂ«—’œ';
                    5:s3 := 'Å«‰’œ';
                    6:s3 := '‘‘’œ';
                    7:s3 := 'Â› ’œ';
                    8:s3 := 'Â‘ ’œ';
                    9:s3 := '‰Â’œ';
               else
                    s3:= '';
               end
         else if c=4 then
              begin
               y4:=y;
               case y of
                    1:s4 := 'Ìﬂ';
                    2:s4 := 'œÊ';
                    3:s4 := '”Â';
                    4:s4 := 'çÂ«—';
                    5:s4 := 'Å‰Ã';
                    6:s4 := '‘‘';
                    7:s4 := 'Â› ';
                    8:s4 := 'Â‘ ';
                    9:s4 := '‰Â';
               else
                    s4:= '';
               end;
              end
         else if c=5 then
              begin
               y5:=y;
               case y of
                    1:s5 := 'œÂ';
                    2:s5 := '»Ì” ';
                    3:s5 := '”Ì';
                    4:s5 := 'çÂ·';
                    5:s5 := 'Å‰Ã«Â';
                    6:s5 := '‘’ ';
                    7:s5 := 'Â› «œ';
                    8:s5 := 'Â‘ «œ';
                    9:s5 := '‰Êœ';
               else
                    s5:= '';
               end;
              end
         else if c=6 then
               case y of
                    1:s6 := '’œ';
                    2:s6 := 'œÊÌ” ';
                    3:s6 := '”Ì’œ';
                    4:s6 := 'çÂ«—’œ';
                    5:s6 := 'Å«‰’œ';
                    6:s6 := '‘‘’œ';
                    7:s6 := 'Â› ’œ';
                    8:s6 := 'Â‘ ’œ';
                    9:s6 := '‰Â’œ';
               else
                    s6:= '';
               end
         else if c=7 then
              begin
              y7:=y;
               case y of
                    1:s7 := 'Ìﬂ';
                    2:s7 := 'œÊ';
                    3:s7 := '”Â';
                    4:s7 := 'çÂ«—';
                    5:s7 := 'Å‰Ã';
                    6:s7 := '‘‘';
                    7:s7 := 'Â› ';
                    8:s7 := 'Â‘ ';
                    9:s7 := '‰Â';

               else
                    s7:= '';
               end;
            end
         else if c=8 then
              begin
               y8:=y;
               case y of
                    1:s8 := 'œÂ';
                    2:s8 := '»Ì” ';
                    3:s8 := '”Ì';
                    4:s8 := 'çÂ·';
                    5:s8 := 'Å‰Ã«Â';
                    6:s8 := '‘’ ';
                    7:s8 := 'Â› «œ';
                    8:s8 := 'Â‘ «œ';
                    9:s8 := '‰Êœ';
               else
                    s8:= '';
               end;
              end
         else if c=9 then
               case y of
                    1:s9 := '’œ';
                    2:s9 := 'œÊÌ” ';
                    3:s9 := '”Ì’œ';
                    4:s9 := 'çÂ«—’œ';
                    5:s9 := 'Å«‰’œ';
                    6:s9 := '‘‘’œ';
                    7:s9 := 'Â› ’œ';
                    8:s9 := 'Â‘ ’œ';
                    9:s9 := '‰Â’œ';
               else
                    s9:= '';
              end
         else if c=10 then
              begin
              y10:=y;
               case y of
                    1:s10 := 'Ìﬂ';
                    2:s10 := 'œÊ';
                    3:s10 := '”Â';
                    4:s10 := 'çÂ«—';
                    5:s10 := 'Å‰Ã';
                    6:s10 := '‘‘';
                    7:s10 := 'Â› ';
                    8:s10 := 'Â‘ ';
                    9:s10 := '‰Â';

               else
                    s10:= '';
               end;
            end
         else if c=11 then
              begin
               y11:=y;
               case y of
                    1:s11 := 'œÂ';
                    2:s11 := '»Ì” ';
                    3:s11 := '”Ì';
                    4:s11 := 'çÂ·';
                    5:s11 := 'Å‰Ã«Â';
                    6:s11 := '‘’ ';
                    7:s11 := 'Â› «œ';
                    8:s11 := 'Â‘ «œ';
                    9:s11 := '‰Êœ';
               else
                    s11:= '';
               end;
              end
         else if c=12 then
               case y of
                    1:s12 := '’œ';
                    2:s12 := 'œÊÌ” ';
                    3:s12 := '”Ì’œ';
                    4:s12 := 'çÂ«—’œ';
                    5:s12 := 'Å«‰’œ';
                    6:s12 := '‘‘’œ';
                    7:s12 := 'Â› ’œ';
                    8:s12 := 'Â‘ ’œ';
                    9:s12:= '‰Â’œ';
               else
                    s12:= '';
              end
         else if c=13 then
              begin
              y13:=y;
               case y of
                    1:s13 := 'Ìﬂ';
                    2:s13 := 'œÊ';
                    3:s13 := '”Â';
                    4:s13 := 'çÂ«—';
                    5:s13 := 'Å‰Ã';
                    6:s13 := '‘‘';
                    7:s13 := 'Â› ';
                    8:s13 := 'Â‘ ';
                    9:s13 := '‰Â';

               else
                    s13:= '';
               end;
            end
         else if c=14 then
              begin
               y14:=y;
               case y of
                    1:s14 := 'œÂ';
                    2:s14 := '»Ì” ';
                    3:s14 := '”Ì';
                    4:s14 := 'çÂ·';
                    5:s14 := 'Å‰Ã«Â';
                    6:s14 := '‘’ ';
                    7:s14 := 'Â› «œ';
                    8:s14 := 'Â‘ «œ';
                    9:s14 := '‰Êœ';
               else
                    s14:= '';
               end;
              end
         else if c=15 then
               case y of
                    1:s15 := '’œ';
                    2:s15 := 'œÊÌ” ';
                    3:s15 := '”Ì’œ';
                    4:s15 := 'çÂ«—’œ';
                    5:s15 := 'Å«‰’œ';
                    6:s15 := '‘‘’œ';
                    7:s15 := 'Â› ’œ';
                    8:s15 := 'Â‘ ’œ';
                    9:s15:= '‰Â’œ';
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
                    1:sk1 := 'Ì«“œÂ';
                    2:sk1 := 'œÊ«“œÂ';
                    3:sk1 := '”Ì“œÂ';
                    4:sk1 := 'çÂ«—œÂ';
                    5:sk1 := 'Å«‰“œÂ';
                    6:sk1 := '‘«‰“œÂ';
                    7:sk1 := 'Â›œÂ';
                    8:sk1 := 'ÂÃœÂ';
                    9:sk1 := '‰Ê“œÂ';
               else
                    sk1:= 'œÂ';
               end
else if (s2 <>'')and (s1<>'') then
     sk1 := s2+' Ê '+ sk1
else if s2<>'' then
     sk1:=s2;
if (s3 <>'')and (sk1<>'') then
     sk1 := s3+' Ê '+ sk1
else if s3<>'' then
     sk1:=s3;
///////
if s4 <>''then
   sk2 := s4;
if y5=1 then
               case y4 of
                    1:sk2 := 'Ì«“œÂ';
                    2:sk2 := 'œÊ«“œÂ';
                    3:sk2 := '”Ì“œÂ';
                    4:sk2 := 'çÂ«—œÂ';
                    5:sk2 := 'Å«‰“œÂ';
                    6:sk2 := '‘«‰“œÂ';
                    7:sk2 := 'Â›œÂ';
                    8:sk2 := 'ÂÃœÂ';
                    9:sk2 := '‰Ê“œÂ';
               else
                    sk2:= 'œÂ';
               end
else if (s5 <>'')and (s4<>'') then
     sk2 := s5+' Ê '+ sk2
else if s5<>'' then
     sk2:=s5;
if (s6 <>'')and (sk2<>'') then
     sk2 := s6+' Ê '+ sk2
else if s6<>'' then
     sk2:=s6;
if (s4<>'')or(s5<>'')or(s6<>'') then
  sk2:=sk2+' Â“«—';
////////////
if s7 <>''then
   sk3 := s7;
if y8=1 then
               case y7 of
                    1:sk3 := 'Ì«“œÂ';
                    2:sk3 := 'œÊ«“œÂ';
                    3:sk3 := '”Ì“œÂ';
                    4:sk3 := 'çÂ«—œÂ';
                    5:sk3 := 'Å«‰“œÂ';
                    6:sk3 := '‘«‰“œÂ';
                    7:sk3 := 'Â›œÂ';
                    8:sk3 := 'ÂÃœÂ';
                    9:sk3 := '‰Ê“œÂ';
               else
                    sk3:= 'œÂ';
               end
else if (s8 <>'')and (s7<>'') then
     sk3 := s8+' Ê '+ sk3
else if s8<>'' then
     sk3:=s8;
if (s9 <>'')and (sk3<>'') then
     sk3 := s9+' Ê '+ sk3
else if s9<>'' then
     sk3:=s9;
if (s7<>'')or(s8<>'')or(s9<>'') then
  sk3:=sk3+' „Ì·ÌÊ‰';
/////////////
if s10 <>''then
   sk4 := s10;
if y11=1 then
               case y10 of
                    1:sk4 := 'Ì«“œÂ';
                    2:sk4 := 'œÊ«“œÂ';
                    3:sk4 := '”Ì“œÂ';
                    4:sk4 := 'çÂ«—œÂ';
                    5:sk4 := 'Å«‰“œÂ';
                    6:sk4 := '‘«‰“œÂ';
                    7:sk4 := 'Â›œÂ';
                    8:sk4 := 'ÂÃœÂ';
                    9:sk4 := '‰Ê“œÂ';
               else
                    sk4:= ' œÂ';
               end
else if (s11 <>'')and (s10<>'') then
     sk4 := s11+' Ê '+ sk4
else if s11<>'' then
     sk4:=s11;
if (s12 <>'')and (sk4<>'') then
     sk4 := s12+' Ê '+ sk4
else if s12<>'' then
     sk4:=s12;
if (s10<>'')or(s11<>'')or(s12<>'') then
  sk4:=sk4+' „Ì·Ì«—œ';
/////
if s13 <>''then
   sk5 := s13;
if y14=1 then
               case y13 of
                    1:sk5 := 'Ì«“œÂ';
                    2:sk5 := 'œÊ«“œÂ';
                    3:sk5 := '”Ì“œÂ';
                    4:sk5 := 'çÂ«—œÂ';
                    5:sk5 := 'Å«‰“œÂ';
                    6:sk5 := '‘«‰“œÂ';
                    7:sk5 := 'Â›œÂ';
                    8:sk5 := 'ÂÃœÂ';
                    9:sk5 := '‰Ê“œÂ';
               else
                    sk5:= 'œÂ';
               end
else if (s14 <>'')and (s13<>'') then
     sk5 := s14+' Ê '+ sk5
else if s14<>'' then
     sk5:=s14;
if (s15 <>'')and (sk5<>'') then
     sk5 := s15+' Ê '+ sk5
else if s15<>'' then
     sk5:=s15;
if (s13<>'')or(s14<>'')or(s15<>'') then
  sk5:=sk5+' »Ì·Ì«—œ';


////////////
sk:='';
if sk1 <>''then
   sk := sk1;

if (sk <>'')and (sk2<>'') then
     sk := sk2+' Ê '+ sk
else if sk2<>'' then
     sk:=sk2;

if (sk <>'')and (sk3<>'') then
     sk := sk3+' Ê '+ sk
else if sk3<>'' then
     sk:=sk3;

if (sk <>'')and (sk4<>'') then
     sk := sk4+' Ê '+ sk
else if sk4<>'' then
     sk:=sk4;
     
if (sk <>'')and (sk5<>'') then
     sk := sk5+' Ê '+ sk
else if sk5<>'' then
     sk:=sk5;
if Negative then
   Result:='„‰›Ì '+sk
else
   Result:=sk
end;

function DayConvert(S:String):String;
begin
     if ((S='3')or(S='03')) then
         Result :='”Ê„'
     else if(S='23') then
         Result :='»Ì”  Ê ”Ê„'
     else if(S='30') then
         Result :='”Ì «„'
     else
         Result:=Convert(S)+'„';
end;

end.
 