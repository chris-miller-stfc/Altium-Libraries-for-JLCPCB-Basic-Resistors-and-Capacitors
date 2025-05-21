function ParsePartsCap(FilePath,ExportFileName,Footprint_C)

String = fileread(FilePath);
Match_Groups = regexp(String,"(.*)[\r\t\n\s](.*)[\r\t\n\s]Basic.*[\n\t\r\s]*([\S].*)[\n\t\r\s]*([\S].*)\n",'tokens','dotexceptnewline');

Comment = strings(size(Match_Groups,2),1);
Description = Comment;
Value_Numeric = Comment;
Value_Numericd = zeros(size(Match_Groups,2),1);
Value = Comment;
Tolerance = Comment;
Voltage = Comment;
Manufacturer_1 = Comment;
Manufacturer_Part_Number_1 = Comment;
Supplier_1 = Comment;
Supplier_Part_Number_1 = Comment;
Library_Ref = Comment;
Footprint_Ref = Comment;
Footprint_Path = Comment;
Library_Path = Comment;
Dielectric = Comment;

for(i=1:size(Match_Groups,2))
    Manufacturer_T = strtrim(Match_Groups{i}{4});
    ManufacturerPartNumber_T = strtrim(Match_Groups{i}{1});
    Supplier_T = 'JLCPCB';
    SupplierPartNumber_T = strtrim(Match_Groups{i}{2});
    Value_String = strtrim(Match_Groups{i}{3});

    TempRegex = regexp(Value_String,"([0-9.k]*V)",'match','dotexceptnewline');
    if(~isempty(TempRegex))
        Voltage_T = TempRegex{1};
    else
        Voltage_T = '';
    end

    TempRegex = regexp(Value_String,"([0-9.]*%)",'match','dotexceptnewline');
    if(~isempty(TempRegex))
        Tolerance_T = TempRegex{1};
    else
        Tolerance_T = '';
    end

    TempRegex = regexp(Value_String,"([0-9.pnu]*)F",'tokens','dotexceptnewline');
    if(~isempty(TempRegex))
        TempRegex = TempRegex{1};
        TempRegex = TempRegex{1};
        Value_S = TempRegex;
        TempRegex = strrep(TempRegex,'p','e-12');
        TempRegex = strrep(TempRegex,'n','e-9');
        TempRegex = strrep(TempRegex,'u','e-6');
        Value_T = TempRegex;
    else
        Value_S = NaN;
        Value_T = '';
    end
        TempRegex = regexp(Value_String,"([XCN][0-9P][A-Z0])",'tokens','dotexceptnewline');
    if(~isempty(TempRegex))
        TempRegex = TempRegex{1};
        Dielectric_T = TempRegex{1};
    else
        Dielectric_T = '';
    end


    Comment(i) = string(['CAP ',Value_S]);
    Description(i) = Value_String;
    Value(i) = string([Value_S,'F']);
    Value_Numeric(i) = string(Value_T);
    Value_Numericd(i) = str2double(Value_T);
    Tolerance(i) = string(Tolerance_T);
    Voltage(i) = string(Voltage_T);
    Dielectric(i) = string(Dielectric_T);
    Manufacturer_1(i) = string(Manufacturer_T);
    Manufacturer_Part_Number_1(i) = string(ManufacturerPartNumber_T);
    Supplier_1(i) = string(Supplier_T);
    Supplier_Part_Number_1(i) = string(SupplierPartNumber_T);
    Library_Ref(i) = "Capacitor";
    Footprint_Ref(i) = Footprint_C;
    Footprint_Path(i) = "Passives.PcbLib";
    Library_Path(i) = "Passives.SchLib";
end

[Value_Numericd,I] = sort(Value_Numericd);
Comment = Comment(I);
Description = Description(I);
Value = Value(I);
Value_Numeric = Value_Numeric(I);
Tolerance = Tolerance(I);
Voltage = Voltage(I);
Manufacturer_1 =Manufacturer_1(I);
Manufacturer_Part_Number_1 = Manufacturer_Part_Number_1(I);
Supplier_1 = Supplier_1(I);
Supplier_Part_Number_1 = Supplier_Part_Number_1(I);
Library_Ref = Library_Ref(I);
Footprint_Ref = Footprint_Ref(I);
Footprint_Path = Footprint_Path(I);
Library_Path = Library_Path(I);
Dielectric = Dielectric(I);

DataBase = table(Comment,Description,Value_Numeric,Value,Tolerance,Dielectric,Voltage,Manufacturer_1,Manufacturer_Part_Number_1,Supplier_1,Supplier_Part_Number_1,Library_Ref,Footprint_Ref,Footprint_Path,Library_Path);
for(i=1:length(DataBase.Properties.VariableNames))
    DataBase.Properties.VariableNames{i} = strrep(DataBase.Properties.VariableNames{i},'_',' ');
end

writetable(DataBase,ExportFileName);
end