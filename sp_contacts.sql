USE [cdb ]
GO

/****** Object:  StoredProcedure [dbo].[UpdateContactPhoneRecords1]    Script Date: 2/7/2016 1:23:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Batch submitted through debugger: SQLQuery7.sql|9|0|C:\Users\Daniel\AppData\Local\Temp\~vs1F90.sql

-- =============================================
-- Author:        Daniel Cassin
-- Create date: 14-Aug-2015
-- Description:    'Clean up' the contact table by
--                putting phone records where they 
--                are supposed to be
-- =============================================

alter procedure [dbo].[UpdateContactPhoneRecords1]
as
begin
    set nocount on;

declare @contactId int;
declare @phone varchar(255);
declare @phone1 varchar(255);
declare @phone2 varchar(255);
declare @phonename1 varchar(255);
declare @phonename2 varchar(255);
declare @fax varchar(255);
declare @otherphone varchar(255);
declare @firstPhone varchar(255);
declare @secondPhone varchar(255);
declare @recordcount int, @rowcount int

-- get work phones ---
create table #WorkPhone(
    rowid int identity(1,1),
    contactid int,
    phone varchar(50),
    phone1 varchar(50),
    phone2 varchar(50),
    phonename1 varchar(50),
    phonename2 varchar(50)
)
insert into #WorkPhone(contactid, phone, phone1, phone2, phonename1, phonename2)
select contactid, phone, phone1, phone2, phonename1, phonename2 from tblcontacts where (phone1 is null or phone1 ='')
set @recordcount = @@rowcount
set @rowcount = 1

while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone = phone, @phone1 = phone1, @phonename1 = phonename1, @phonename2 = phonename2, @phone2 = phone2
        from #WorkPhone
        where rowid = @rowcount
        if (@phonename1 like '%work%' or @phonename1 like '%wk%' or @phonename1 like '%business%' or @phonename1 like '%office%') 
                and @phone1 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
                update tblcontacts set phone = @phone1, phone1 = null, phonename1 = null where contactid = @contactId;
                insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
                values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
                ', moved from mobile phone to work phone field'), 0, 0, 'Public', 0);
        end
        if (@phonename2 like '%work%' or @phonename2 like '%wk%' or @phonename2 like '%business%' or @phonename2 like '%office%') 
            and @phone2 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
            update tblcontacts set phone = @phone2, phonename2 = null, phone2 = null where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
            ', moved from home phone to work phone field'), 0, 0, 'Public', 0);
        end
        set @rowcount = @rowcount + 1
    end
drop table #WorkPhone
-- end work phones ---

-- get phone1 phones ----
create table #Phone1(
    rowid int identity(1,1),
    contactid int,
    phone1 varchar(50),
    phone2 varchar(50),
    phonename1 varchar(50),
    phonename2 varchar(50)
)
insert into #Phone1(contactid, phone1, phone2, phonename1, phonename2)
select contactid, phone1, phone2, phonename1, phonename2 from tblcontacts where (phone1 is null or phone1 ='')
set @recordcount = @@rowcount
set @rowcount = 1

while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone1 = phone1, @phonename1 = phonename1, @phonename2 = phonename2, @phone2 = phone2
        from #Phone1
        where rowid = @rowcount
            if (@phonename2 like '%mob%' or @phonename2 like '%cell%') and @phone2 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
                update tblcontacts set phone1 = @phone2, phonename1 = 'Mobile', phone2 = null, phonename2 = null where contactid = @contactId;
                insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
                values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
                ', moved from home phone to mobile phone field'), 0, 0, 'Public', 0);
            end 
            set @rowcount = @rowcount + 1
    end
drop table #Phone1
-- end phone1

-- get phone2 phones ---        
create table #Phone2(
    rowid int identity(1,1),
    contactid int,
    phone1 varchar(50),
    phone2 varchar(50),
    phonename1 varchar(50),
    phonename2 varchar(50)
)
insert into #Phone2(contactid, phone1, phone2, phonename1, phonename2)
select contactid, phone1, phone2, phonename1, phonename2 from tblcontacts where (phone2 is null or phone2 ='')
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone1 = phone1, @phonename1 = phonename1, @phonename2 = phonename2, @phone2 = phone2
        from #Phone2
        where rowid = @rowcount
        
        if (@phonename1 like '%home%' or @phonename1 like '%hm%') and @phone1 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
                update tblcontacts set phone2 = @phone1, phonename2 = 'Home', phone1 = null, phonename1 = null where contactid = @contactId;
                insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
                values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
                ', moved from mobile phone to home phone field'), 0, 0, 'Public', 0);
        end
        set @rowcount = @rowcount + 1
    end
drop table #Phone2
-- end get phone2 phones ---

--get fax phones ---
create table #Fax(
    rowid int identity(1,1),
    contactid int,
    phone1 varchar(50),
    phone2 varchar(50),
    phonename1 varchar(50),
    phonename2 varchar(50),
    fax varchar(50)
)
insert into #Fax(contactid, phone1, phone2, phonename1, phonename2, fax)
select contactid, phone1, phone2, phonename1, phonename2, fax from tblcontacts where (fax is null or fax ='')
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone1 = phone1, @phonename1 = phonename1, @phonename2 = phonename2, @phone2 = phone2, @fax = fax
        from #Fax
        where rowid = @rowcount
        if @phonename1 like '%fax%' and @phone1 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
            update tblcontacts set fax = @phone1 where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
            ', moved from mobile phone to fax field'), 0, 0, 'Public', 0);
        end
        if @phonename2 like '%fax%' and @phone2 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
            update tblcontacts set fax = @phone2 where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
            ', moved from home phone to fax field'), 0, 0, 'Public', 0);
        end 
        set @rowcount = @rowcount + 1
    end
drop table #Fax
-- end get fax phones ---

-- get mobile phones ---
create table #Mobile(
    rowid int identity(1,1),
    contactid int,
    phone1 varchar(50),
    phonename1 varchar(50),
    otherphone varchar(50)
)
insert into #Mobile(contactid, phone1, phonename1, otherphone)
select contactid, phone1, phonename1, otherphone from tblcontacts where phonename1 not like '%mob%' and phonename1 not like '%cell%' 
and phone1 is not null and phone1 !=''; 
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone1 = phone1, @phonename1 = phonename1, @otherphone = otherphone 
        from #Mobile
        where rowid = @rowcount
        if @otherphone is null or @otherphone = '' begin
            update tblcontacts set otherphone = phone1, phone1 = null, phonename1 = null where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
            ', moved from mobile phone to other phone field'), 0, 0, 'Public', 0);
        end
        else begin
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
            ', moved from mobile phone to notes'), 0, 0, 'Public', 0);
        end 
        set @rowcount = @rowcount + 1
    end 
drop table #Mobile
-- end get mobile phones ---

-- get home phones ---    
create table #Home(
    rowid int identity(1,1),
    contactid int,
    phone2 varchar(50),
    phonename2 varchar(50),
    otherphone varchar(50)
)
insert into #Home(contactid, phone2, phonename2, otherphone)
select contactid, phone2, phonename2, otherphone from tblcontacts where phonename2 not like '%hm%' and phonename2 not like '%home%' 
and phone2 is not null and phone2 !=''; 
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone2 = phone2, @phonename2 = phonename2, @otherphone = otherphone
        from #Home
        where rowid = @rowcount
        if @otherphone is null or @otherphone = '' begin
            update tblcontacts set otherphone = phone2, phone2 = null, phonename2 = null where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
            ', moved from home phone to other phone field'), 0, 0, 'Public', 0);
        end
        else begin
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
                values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
                ', moved from home phone to notes'), 0, 0, 'Public', 0);
        end 
        set @rowcount = @rowcount + 1
    end
drop table #Home
-- end get home phones ---

-- set mobile ---
create table #SetMobile(
    rowid int identity(1,1),
    contactid int,
    phone1 varchar(50),
    phonename1 varchar(50),
    otherphone varchar(50)
)
insert into #SetMobile(contactid, phone1, phonename1, otherphone)
select contactid, phone1, phonename1, otherphone from tblcontacts;
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone1 = phone1, @phonename1 = phonename1, @otherphone = otherphone 
        from #SetMobile
        where rowid = @rowcount
        if (@phonename1 like '%mob%' or @phonename1 like '%cell%') and @phone1 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' 
        and @phone1 is not null and @phone1 != '' begin
            update tblcontacts set phonename1 = 'Mobile' where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
            ', changed to Mobile'), 0, 0, 'Public', 0);
        end
        if (@otherphone is null or @otherphone = '') and @phone1 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
            update tblcontacts set otherphone = @phone1, phonename1 = null, phone1 = null where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
            ', moved from mobile phone to other phone field'), 0, 0, 'Public', 0);
        end 
        else begin
            update tblcontacts set phone1 = null, phonename1 = null where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'listed as ', replace(@phonename1, '''', ''), 
            ', moved from mobile phone to notes'), 0, 0, 'Public', 0);
        end
        set @rowcount = @rowcount + 1
    end
drop table #SetMobile
--end set mobile ---

-- set home ---
create table #SetHome(
    rowid int identity(1,1),
    contactid int,
    phone2 varchar(50),
    phonename2 varchar(50),
    otherphone varchar(50)
)
insert into #SetHome
select contactid, phone2, phonename2, otherphone from tblcontacts
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
    select @contactid = contactid, @phone2 = phone2, @phonename2 = phonename2, @otherphone = otherphone
    from #SetHome
    where rowid = @rowcount
        if (@phonename2 like '%hm%' or @phonename2 like '%home%') and @phone2 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' 
        and @phone2 is not null and @phone2 != '' begin
            update tblcontacts set phonename2 = 'Home' where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
            ', changed to Home'), 0, 0, 'Public', 0);
        end
        if (@otherphone is null or @otherphone = '') and @phone2 like '^[0-9]+\.[0-9]+(\.[0-9]+)*' begin
            update tblcontacts set otherphone = @phone2, phone2 = null, phonename2 = null where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
            ', moved from home phone to other phone field'), 0, 0, 'Public', 0);
        end
        else begin
            update tblcontacts set @phone2 = null, @phonename2 = null where contactid = @contactId;
            insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
            values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone2, '''', ''),'listed as ', replace(@phonename2, '''', ''), 
            ', moved from home phone to notes'), 0, 0, 'Public', 0);
        end
        set @rowcount = @rowcount + 1
    end
drop table #SetHome
-- end set home ---

create table #WorkSplit(
    rowid int identity(1,1),
    contactid int,
    phone varchar(50)
)
insert into #WorkSplit(contactid, phone)
select contactid, phone from tblcontacts where phone like '^[0-9]+\.[0-9]+(\.[0-9]+)* / ^[0-9]+\.[0-9]+(\.[0-9]+)*' and len(phone) > 12; 
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        select @contactid = contactid, @phone = phone
        from #WorkSplit
        where rowid = @rowcount
        set @firstPhone = (select substring(@phone, 0, charindex('/', @phone)));
        set @secondPhone = (select substring(@phone, charindex('/', -1), len(@phone)));
        update tblcontacts set phone = @firstPhone, otherphone = @secondPhone where contactid=@contactId;
        insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
        values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone, '''', ''),'multiple numbers in phone field ', 
        replace(@secondPhone, '''', ''), 
        ', moved from phone to other phone field'), 0, 0, 'Public', 0);
    set @rowcount = @rowcount + 1
    end 
drop table #WorkSplit

-- mobile splits ---
create table #MobileSplit(
    rowid int identity(1,1),
    contactid int,
    phone1 varchar(50)
)
insert into #MobileSplit(contactid, phone1)
select contactid, phone1 from tblcontacts where phone1 like '^[0-9]+\.[0-9]+(\.[0-9]+)* / ^[0-9]+\.[0-9]+(\.[0-9]+)*' and len(phone1) > 12;
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        set @firstPhone = (select substring(@phone1, 0, charindex('/', 1)));
        set @secondPhone = (select substring(@phone1, 0, charindex('/', -1)));
        update tblcontacts set phone1 = @firstPhone, otherphone = @secondPhone where contactid=@contactId;
        insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
        values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone, '''', ''),'multiple numbers in mobile phone field ', 
        replace(@secondPhone, '''', ''), 
        ', moved from mobile phone to other phone field'), 0, 0, 'Public', 0);
    set @rowcount = @rowcount + 1
    end    
drop table #MobileSplit
-- end mobile splits ---

-- home splits --
create table #HomeSplit(
    rowid int identity(1,1),
    contactid int,
    phone2 varchar(50)
)
insert into #HomeSplit(contactid, phone2)
select contactid, phone2 from tblcontacts where phone2 like '^[0-9]+\.[0-9]+(\.[0-9]+)* / ^[0-9]+\.[0-9]+(\.[0-9]+)*' and len(phone2) > 12;
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        set @firstPhone = (select substring(@phone2, 0, charindex('/', 1)));
        set @secondPhone = (select substring(@phone2, 0, charindex('/', -1)));
        update tblcontacts set phone2 = @firstPhone, otherphone = @secondPhone where contactid=@contactId;
        insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
        values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@phone1, '''', ''),'multiple numbers in home phone field ', 
        replace(@secondPhone, '''', ''), 
        ', moved from home phone to other phone field'), 0, 0, 'Public', 0);
    set @rowcount = @rowcount + 1
    end
drop table #HomeSplit
-- end home splits ---

-- fax splits ---
create table #FaxSplits(
    rowid int identity(1,1),
    contactid int,
    fax varchar(50)
)
insert into #FaxSplits(contactid, fax)
select contactid, fax from tblcontacts where fax like '^[0-9]+\.[0-9]+(\.[0-9]+)* / ^[0-9]+\.[0-9]+(\.[0-9]+)*' and len(fax) > 12;
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        set @firstPhone = (select substring(@fax, 0, charindex('/', 1)));
        set @secondPhone = (select substring(@fax, 0, charindex('/', -1)));
        update tblcontacts set @fax = @firstPhone, otherphone = @secondPhone where contactid=@contactId;
        insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
        values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@fax, '''', ''),'multiple numbers in fax field ', 
            replace(@secondPhone, '''', ''), 
        ', moved from fax to other phone field'), 0, 0, 'Public', 0);
    set @rowcount = @rowcount + 1
    end
drop table #FaxSplits
-- end fax splits ---

-- other splits ---
create table #OtherSplits(
    rowid int identity(1,1),
    contactid int,
    fax varchar(50)
)
insert into #OtherSplits(contactid, fax)
select contactid, fax from tblcontacts where otherphone like '^[0-9]+\.[0-9]+(\.[0-9]+)* / ^[0-9]+\.[0-9]+(\.[0-9]+)*' and len(otherphone) > 12;
set @recordcount = @@rowcount
set @rowcount = 1
while @rowcount <= @recordcount
    begin
        set @firstPhone = (select substring(@otherphone, 0, charindex('/', 1)));
        set @secondPhone = (select substring(@otherphone, 0, charindex('/', -1)));
        update tblcontacts set otherphone = @firstPhone where contactid = @contactId;
        insert tblnotes (created, parenttype, parentid, creator, notes, private, shared, access, sticky) 
        values(getdate(), 'Contact', @contactId, 'System', CONCAT(replace(@otherphone, '''', ''),'multiple numbers in other phone field ', 
            replace(@secondPhone, '''', ''), 
        ', moved from other phone field to notes'), 0, 0, 'Public', 0);
    set @rowcount = @rowcount + 1
    end
drop table #OtherSplits
-- end other splits ---
END


GO