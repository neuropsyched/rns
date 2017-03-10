function [data] = rns_accessmssql_server(inputstr)

if isempty(strfind(inputstr,' '))
    sqlquery = ['select * from rns_dm.' inputstr];
else
    sqlquery = inputstr;
end
% Cronus IP: 136.142.76.71
% MSSQL Port: 1433
conn = database('RNS','rns','brains','Vendor',...
    'Microsoft SQL Server','Server','136.142.76.71',...
    'AuthType','Server','PortNumber',1433);

curs = exec(conn,sqlquery);
curs = fetch(curs);

data = table2struct(curs.Data);

end


% function [data] = rns_accessmssql_server(PtId)
% %     rns_accessmssql('GN765937');
% 
% if nargin<1
%     sqlquery = 'select * from rns_dm.data';
%     disp('Warning output structure contains data from all patients!!')
% else 
%     sqlquery = ['select * from rns_dm.data d where d.pt_id = ''' PtId ''''];
% end
% 
% % Cronus IP: 136.142.76.71
% % MSSQL Port: 1433
% conn = database('RNS','rns','brains','Vendor',...
%     'Microsoft SQL Server','Server','136.142.76.71',...
%     'AuthType','Server','PortNumber',1433);
% 
% curs = exec(conn,sqlquery);
% curs = fetch(curs);
% 
% data = table2struct(curs.Data);
% 
% end