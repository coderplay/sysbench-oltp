-- Copyright (C) 2006-2017 Vadim Tkachenko, Percona

-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

-- -----------------------------------------------------------------------------
-- Check data code for TPCC benchmarks.
-- -----------------------------------------------------------------------------


require("tpcc_common")


function check_tables(drv, con, warehouse_num)

    local pass1 = 1
    for table_num = 1, sysbench.opt.tables do 
        -- print(string.format("Checking  tables: %d for warehouse: %d\n", table_num, warehouse_num))
        rs  = con:query("SELECT d_w_id,sum(d_ytd)-w_ytd diff FROM district"..table_num..",warehouse"..table_num.." where d_w_id=w_id AND w_id="..warehouse_num.." group by d_w_id") 
        
        for i = 1, rs.nrows do
            row = rs:fetch_row()
            local d_tax = tonumber(row[2])
            if d_tax ~= 0 then
                pass1=0
                print(string.format("Check 1, warehouse: %d, table %d FAILED!!!", warehouse_num, table_num))
            end
        end
    end
    
    if pass1 ~= 1 then
        print(string.format("Check 1, warehouse: %d FAILED!!!", warehouse_num))
    end

-- CHECK 2 
-- select dis.d_id, d_next_o_id-1,mo,mno from district1 dis, (select o_d_id,max(o_id) mo from orders1 where o_w_id=1 group by o_d_id) q, (select no_d_id,max(no_o_id) mno from new_orders1 where no_w_id=1 group by no_d_id) no where d_w_id=1 and q.o_d_id=dis.d_id and no.no_d_id=dis.d_id


    local pass2 = 1
    for table_num = 1, sysbench.opt.tables do 
        -- print(string.format("Checking  tables: %d for warehouse: %d\n", table_num, warehouse_num))
        rs  = con:query(string.format("SELECT dis.d_id, d_next_o_id-1,mo,mno FROM district%d dis, (SELECT o_d_id,max(o_id) mo FROM orders%d WHERE o_w_id=%d GROUP BY o_d_id) q, (select no_d_id,max(no_o_id) mno from new_orders%d where no_w_id=%d group by no_d_id) no where d_w_id=%d and q.o_d_id=dis.d_id and no.no_d_id=dis.d_id", table_num,table_num,warehouse_num, table_num, warehouse_num, warehouse_num))
        
        for i = 1, rs.nrows do
            row = rs:fetch_row()
            local d1 = tonumber(row[2])
            local d2 = tonumber(row[3])
            local d3 = tonumber(row[4])
            if d1 ~= d2 then
                pass2=0
            end
            if d1 ~= d3 then
                pass2=0
            end
        end
    end
    
    if pass2 == 1 then
        print(string.format("Check 2, warehouse: %d PASSED", warehouse_num))
    else
        print(string.format("Check 2, warehouse: %d FAILED!!!", warehouse_num))
    end

    local pass3 = 1
    for table_num = 1, sysbench.opt.tables do 
        -- print(string.format("Checking  tables: %d for warehouse: %d\n", table_num, warehouse_num))
        rs  = con:query(string.format("select no_d_id,max(no_o_id)-min(no_o_id)+1,count(*) from new_orders%d where no_w_id=%d group by no_d_id",table_num, warehouse_num))
        
        for i = 1, rs.nrows do
            row = rs:fetch_row()
            local d1 = tonumber(row[2])
            local d2 = tonumber(row[3])
            if d1 ~= d2 then
                pass3=0
            end
        end
    end
    
    if pass3 == 1 then
        print(string.format("Check 3, warehouse: %d PASSED", warehouse_num))
    else
        print(string.format("Check 3, warehouse: %d FAILED!!!", warehouse_num))
    end

    local pass4 = 1
    for table_num = 1, sysbench.opt.tables do 
        -- print(string.format("Checking  tables: %d for warehouse: %d\n", table_num, warehouse_num))
        rs  = con:query(string.format("SELECT count(*) FROM (SELECT o_d_id, SUM(o_ol_cnt) sm1, cn FROM orders%d,(SELECT ol_d_id, COUNT(*) cn FROM order_line%d WHERE ol_w_id=%d GROUP BY ol_d_id) ol WHERE O_w_id=%d AND ol_d_id=o_d_id GROUP BY o_d_id) t1 WHERE sm1<>cn",table_num, table_num, warehouse_num, warehouse_num))
        
        for i = 1, rs.nrows do
            row = rs:fetch_row()
            local d1 = tonumber(row[1])
            if d1 ~= 0 then
                pass4=0
            end
        end
    end
    
    if pass4 == 1 then
        print(string.format("Check 4, warehouse: %d PASSED", warehouse_num))
    else
        print(string.format("Check 4, warehouse: %d FAILED!!!", warehouse_num))
    end

    local pass8 = 1
    for table_num = 1, sysbench.opt.tables do 
        -- print(string.format("Checking  tables: %d for warehouse: %d\n", table_num, warehouse_num))
        rs  = con:query(string.format("SELECT count(*) cn FROM (SELECT w_id,w_ytd,SUM(h_amount) sm FROM history%d,warehouse%d WHERE h_w_id=w_id and w_id=%d GROUP BY w_id) t1 WHERE w_ytd<>sm",table_num, table_num, warehouse_num))
        
        for i = 1, rs.nrows do
            row = rs:fetch_row()
            local d1 = tonumber(row[1])
            if d1 ~= 0 then
                pass8=0
            end
        end
    end
    
    if pass8 == 1 then
        print(string.format("Check 8, warehouse: %d PASSED", warehouse_num))
    else
        print(string.format("Check 8, warehouse: %d FAILED!!!", warehouse_num))
    end

    local pass9 = 1
    for table_num = 1, sysbench.opt.tables do 
        -- print(string.format("Checking  tables: %d for warehouse: %d\n", table_num, warehouse_num))
        rs  = con:query(string.format("SELECT COUNT(*) FROM (select d_id,d_w_id,sum(d_ytd) s1 from district%d group by d_id,d_w_id) d,(select h_d_id,h_w_id,sum(h_amount) s2 from history%d group by h_d_id, h_w_id) h WHERE h_d_id=d_id AND d_w_id=h_w_id and d_w_id=%d and s1<>s2",table_num, table_num, warehouse_num))
        
        for i = 1, rs.nrows do
            row = rs:fetch_row()
            local d1 = tonumber(row[1])
            if d1 ~= 0 then
                pass9=0
            end
        end
    end
    
    if pass9 == 1 then
        print(string.format("Check 9, warehouse: %d PASSED", warehouse_num))
    else
        print(string.format("Check 9, warehouse: %d FAILED!!!", warehouse_num))
    end
end


-- vim:ts=4 ss=4 sw=4 expandtab