--
-- Удаляем таблицы если существуют
--

drop table if exists completed_works;
drop table if exists car_maintenance;
drop table if exists cars_owners;
drop table if exists cars;
drop table if exists people;
drop table if exists car_series;
drop table if exists car_makers;

--
-- Создаем таблицы
--

-- Производители автомобилей
create table car_makers
(
    car_maker_id serial primary key, -- Идентификатор производителя
    maker_name   text not null,      -- Наименование производителя
    brand        text not null       -- Брэнд
);


-- Серии автомобилей
create table car_series
(
    car_series_id        serial primary key,                                    -- Идентификатор серии
    car_maker_id         integer not null references car_makers (car_maker_id), -- Идентификатор производителя
    series_name          text    not null,                                      -- Наименование серии
    start_of_production  integer not null,                                      -- Год начала проивзодства
    finish_of_production integer not null                                       -- Год завершения проивзодства
);


-- Автомобили
create table cars
(
    car_id        serial primary key,                                     -- Идентификатор автомобиля
    car_maker_id  integer not null references car_makers (car_maker_id),  -- Идентификатор производителя
    car_series_id integer not null references car_series (car_series_id), -- Идентификатор серии
    year          integer not null,                                       -- Год выпуска
    color         text    not null,                                       -- Цвет
    car_number    text,                                                   -- Номер автомобиля
    body_number   text,                                                   -- Номер кузова
    engine_number text                                                    -- Номер двигателя
);

-- Физический лица
create table people
(
    person_id  serial primary key, -- Идентификатор
    first_name text not null,      -- Имя
    last_name  text not null,      -- Фамилия
    birth_date date,               -- Дата рождения
    sex        text,               -- Пол
    address    text,               -- Ардес
    phone      text,               -- Телефон
    e_mail     text                -- Электронная почта
);


-- Владение автомобилями
create table cars_owners
(
    car_owner_id   serial primary key,                             -- Идентификатор
    car_id         integer not null references cars (car_id),      -- Идентификатор автомобиля
    person_id      integer not null references people (person_id), -- Идентификатор владельца
    start_date     date    not null,                               -- Начало владения
    finish_date    date,                                           -- Завершение владения
    start_mileage  integer,                                        -- Пробег на начало владения
    finish_mileage integer                                         -- Пробег на завершения владения
);


-- Техническое обслуживание автомобилей
create table car_maintenance
(
    car_maintenance_id serial primary key,                        -- Идентификатор
    car_id             integer not null references cars (car_id), -- Идентификатор автомобиля
    date               date    not null,                          -- Дата обслуживания
    note               text                                       -- Примечание
);

-- Выполненные работы
create table completed_works
(
    completed_work_id   serial primary key,                                               -- Идентификатор
    car_maintenance_id  integer not null references car_maintenance (car_maintenance_id), -- Идентификатор обслуживания
    problem_description text    not null,                                                 -- Описание проблемы
    work_description    text    not null,                                                 -- Описание выполненной работы
    replaced_parts      text                                                              -- Замененные детали
);

--
-- Заполняем таблицы тестовыми данными
--

do
$$
    declare
    begin
        for i in 1 .. 10
            loop

                -- Заполняем таблицу car_makers
                insert into car_makers(car_maker_id, maker_name, brand)
                values (i, ('maker_name_' || i::text), ('brand_' || i::text));

                -- Заполняем таблицу people
                insert into people(person_id, first_name, last_name)
                values (i, ('first_name_' || i::text), ('last_name_' || i::text));


                for j in 1 .. 10
                    loop

                        -- Заполняем таблицу car_series
                        insert into car_series(car_series_id, car_maker_id, series_name, start_of_production,
                                               finish_of_production)
                        values (((i - 1) * 10 + j), i, 'series_name_' || ((i - 1) * 10 + j)::text, (1980 + j),
                                (1990 + j));

                        for k in 1 .. 1000
                            loop

                                -- Заполняем таблицу cars
                                insert into cars(car_id,
                                                 car_maker_id,
                                                 car_series_id,
                                                 year,
                                                 color,
                                                 car_number,
                                                 body_number,
                                                 engine_number)
                                values ((((i - 1) * 1000 + j) * 1000 + k - 1000),
                                        i,
                                        ((i - 1) * 10 + j),
                                        1990,
                                        ('color_' || k::text),
                                        'car_number_' || (((i - 1) * 1000 + j) * 1000 + k - 1000)::text,
                                        'body_number_' || (((i - 1) * 1000 + j) * 1000 + k - 1000)::text,
                                        'engine_number_' || (((i - 1) * 1000 + j) * 1000 + k - 1000)::text);
                            end loop;

                    end loop;

            end loop;
    end
$$;

select c.color, count(p.person_id) as count
from people p
         join cars_owners co on p.person_id = co.person_id
         join cars c on c.car_id = co.car_id
where p.sex = 'female'
group by c.color;

select avg(c.car_id), cw.replaced_parts
from people p
         join cars_owners co on p.person_id = co.person_id
         join cars c on c.car_id = co.car_id
         join car_maintenance cm on c.car_id = cm.car_id
         join completed_works cw on cm.car_maintenance_id = cw.car_maintenance_id
where cm.note = 'inspection'
group by cw.replaced_parts;

select cm.brand, avg(cs.finish_of_production) as avg_year
from car_series cs
         join car_makers cm on cm.car_maker_id = cs.car_maker_id
where cs.start_of_production > 1981
  and (cm.brand = 'brand_2' or cm.brand = 'brand_6')
group by cm.brand;

select avg(cc.owners) as owners, c.year
from cars c
         join (
    select count(co.person_id) as owners,
           co.car_id
    from cars_owners co
    group by co.car_id) cc on cc.car_id = c.car_id
group by c.year;

select p.sex, avg(co.start_mileage) as average_start_mileage
from people p
         join cars_owners co on p.person_id = co.person_id
where co.start_date > '2021-05-03'
group by p.sex;

select *
from car_makers;
select *
from people;
select *
from car_series;
select *
from cars;
select *
from car_maintenance;
select *
from cars_owners;
select *
from completed_works;

delete
from cars;
delete
from car_series;
delete
from car_makers;
delete
from people;
