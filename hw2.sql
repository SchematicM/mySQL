# 1.Вибрати усіх клієнтів, чиє ім'я має менше ніж 6 символів.
select *
from client
where length(FirstName) < 6;

# 2.Вибрати львівські відділення банку.
select *
from department
where DepartmentCity = 'lviv';

# 3.Вибрати клієнтів з вищою освітою та посортувати по прізвищу.
select *
from client
where Education = 'high'
order by LastName;
#
# 4.Виконати сортування у зворотньому порядку над таблицею Заявка і вивести 5 останніх елементів.
select *
from application
order by idApplication desc
limit 5;
#
# 5.Вивести усіх клієнтів, чиє прізвище закінчується на OV чи OVA.

select *
from client
where LastName like '%ov'
   or LastName like 'ova';

# 6.Вивести клієнтів банку, які обслуговуються київськими відділеннями.
select *
from client
         join department a on client.idClient = a.idDepartment
where a.DepartmentCity = 'kyiv';

# 7.Знайти унікальні імена клієнтів.
select distinct FirstName
from client;

# 8.Вивести дані про клієнтів, які мають кредит більше ніж на 5000 гривень.
select *
from client
         join application a on client.idClient = a.Client_idClient
where a.Sum > 5000;

# 9.Порахувати кількість клієнтів усіх відділень та лише львівських відділень.
select d.idDepartment, count(*) as client_count
from client c
         join department d on c.Department_idDepartment = d.idDepartment
where d.DepartmentCity = 'Lviv'
group by d.idDepartment;

# 10.Знайти кредити, які мають найбільшу суму для кожного клієнта окремо.
select idClient, max(a.Sum) as max_credit
from client
         join department d on client.Department_idDepartment = d.idDepartment
         join application a on client.idClient = a.Client_idClient
group by idClient;

# 11. Визначити кількість заявок на крдеит для кожного клієнта.
select idClient, count(a.Client_idClient) as credit_count
from client
         join department d on client.Department_idDepartment = d.idDepartment
         join application a on client.idClient = a.Client_idClient
group by a.Client_idClient
order by a.Client_idClient;

# 12. Визначити найбільший та найменший кредити.
select max(a.Sum) as max_credit, min(a.Sum) as min_credit
from client
         join department d on client.Department_idDepartment = d.idDepartment
         join application a on client.idClient = a.Client_idClient;

# 13. Порахувати кількість кредитів для клієнтів,які мають вищу освіту.
select c.FirstName, c.idClient, count(*) as count_credit
from client c
         join application a on c.idClient = a.Client_idClient
where c.Education = 'High'
group by c.idClient;

# 14. Вивести дані про клієнта, в якого середня сума кредитів найвища.
select c.*, avg(a.Sum) as avg_sum
from client c
         join application a on c.idClient = a.Client_idClient
group by c.idClient
order by avg_sum desc
limit 1;

# 15. Вивести відділення, яке видало в кредити найбільше грошей
select d.idDepartment, sum(a.Sum) sum_by_department
from client
         join department d on client.Department_idDepartment = d.idDepartment
         join application a on client.idClient = a.Client_idClient
group by d.idDepartment
order by sum_by_department desc
limit 1;

# 16. Вивести відділення, яке видало найбільший кредит.
select d.idDepartment, max(a.Sum) max_by_department
from client
         join department d on client.Department_idDepartment = d.idDepartment
         join application a on client.idClient = a.Client_idClient
group by d.idDepartment
order by max_by_department desc
limit 1;

# 17. Усім клієнтам, які мають вищу освіту, встановити усі їхні кредити у розмірі 6000 грн.
update application a
set a.Sum = 6000
where a.Client_idClient in
      (select c.idClient from client c where c.Education = 'high');

# 18. Усіх клієнтів київських відділень пересилити до Києва.
update client c
set c.City = 'Kyiv'
where c.Department_idDepartment in
      (select d.idDepartment from department d where d.DepartmentCity = 'Kyiv');

# 19. Видалити усі кредити, які є повернені.
delete
from application a
where a.CreditState = 'Returned';

# 20. Видалити кредити клієнтів, в яких друга літера прізвища є голосною.
delete
from application a
where a.Client_idClient in
      (select c.idClient from client c where c.LastName regexp '^.[aeoui].*$');

# 21.Знайти львівські відділення, які видали кредитів на загальну суму більше ніж 5000
select d.idDepartment, sum(a.Sum) as credit_sum
from client c
         join department d on c.Department_idDepartment = d.idDepartment
         join application a on c.idClient = a.Client_idClient
where d.DepartmentCity = 'Lviv'
group by d.idDepartment
having credit_sum > 5000;

# 22.Знайти клієнтів, які повністю погасили кредити на суму більше ніж 5000
select c.idClient, a.Sum
from client c
         join application a on c.idClient = a.Client_idClient
where a.CreditState = 'Returned'
  and a.Sum > 5000;

# 23.Знайти максимальний неповернений кредит.
select *
from application a
where a.CreditState = 'Not returned'
  and a.Sum = (select max(Sum) from application);

# 24.Знайти клієнта, сума кредиту якого найменша
select c.*, a.Sum
from application a
         join client c on a.Client_idClient = c.idClient
where a.Sum = (select min(Sum) from application);

# 25.Знайти кредити, сума яких більша за середнє значення усіх кредитів
select *
from application a
where a.Sum > (select avg(a.Sum) from application a);

# 26. Знайти клієнтів, які є з того самого міста, що і клієнт, який взяв найбільшу кількість кредитів
select *
from client c
where c.City = (select City
                from (select c.City, count(*) as credit_count
                      from client c
                               join application a on c.idClient = a.Client_idClient
                      group by c.idClient
                      order by credit_count desc
                      limit 1) as subquery);

# 27. Місто клієнта з найбільшою кількістю кредитів
select City
from (select c.City, count(*) as credit_count
      from client c
               join application a on c.idClient = a.Client_idClient
      group by c.idClient
      order by credit_count desc
      limit 1) as subquery;