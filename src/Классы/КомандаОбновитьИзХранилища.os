﻿
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Обновить из хранилища подключенную базу");

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "СтрокаПодключения", "Строка подключения к рабочему контуру");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "АдресХранилища", "Путь или сетевой адрес хранилища 1С");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-user",
		"Пользователь информационной базы");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-pwd",
		"Пароль пользователя информационной базы");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-user",
		"Пользователь хранилища конфигурации");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-pwd",
		"Пароль пользователя хранилища конфигурации");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-ver",
		"Версия (номер) закладки в хранилище - необязательно");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-extension",
		"Имя расширения");

    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-v8version",
    	"Маска версии платформы 1С");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-uccode",
    	"Ключ разрешения запуска");

    Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	СтрокаПодключения = ПараметрыКоманды["СтрокаПодключения"];
	АдресХранилища    = ПараметрыКоманды["АдресХранилища"];
	ПользовательБазы  = ПараметрыКоманды["-db-user"];
	ПарольПользователяБазы  = ПараметрыКоманды["-db-pwd"];

	ПользовательХранилища       = ПараметрыКоманды["-storage-user"];
	ПарольПользователяХранилища = ПараметрыКоманды["-storage-pwd"];
	ВерсияХранилища             = ПараметрыКоманды["-storage-ver"];

	МаскаВерсии = ПараметрыКоманды["-v8version"];
	КлючРазрешенияЗапуска       = ПараметрыКоманды["-uccode"];

	ИмяРасширения = ПараметрыКоманды["-extension"];

	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();

	Если ПустаяСтрока(СтрокаПодключения) Тогда
		Лог.Ошибка("Не задана строка подключения к базе");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(АдресХранилища) Тогда
		Лог.Ошибка("Не задана строка подключения к хранилищу");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(ПользовательХранилища) Тогда
		Лог.Ошибка("Не задан пользователь хранилища");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Конфигуратор = ЗапускПриложений.НастроитьКонфигуратор(
			СтрокаПодключения, ПользовательБазы, ПарольПользователяБазы, МаскаВерсии);
	
	Если Не ПустаяСтрока(КлючРазрешенияЗапуска) Тогда
		Конфигуратор.УстановитьКлючРазрешенияЗапуска(КлючРазрешенияЗапуска);
	КонецЕсли;
	
	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();

	Параметры.Добавить("/ConfigurationRepositoryF """+АдресХранилища+"""");
	Параметры.Добавить("/ConfigurationRepositoryN """+ПользовательХранилища+"""");

	Если Не ПустаяСтрока(ПарольПользователяХранилища) Тогда
		Параметры.Добавить("/ConfigurationRepositoryP """+ПарольПользователяХранилища+"""");
	КонецЕсли;

	Параметры.Добавить("/ConfigurationRepositoryUpdateCfg"); 
	Параметры.Добавить("-force");
	Если Не ПустаяСтрока(ВерсияХранилища) Тогда
		Параметры.Добавить("-v" + ВерсияХранилища);
	КонецЕсли;

	Если Не ПустаяСтрока(ИмяРасширения) Тогда
		Параметры.Добавить("-extension " + ИмяРасширения);
	КонецЕсли;

	Попытка
		Конфигуратор.ВыполнитьКоманду(Параметры);
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			Лог.Информация(Текст);
		КонецЕсли;

		Возврат ВозможныйРезультат.Успех;
	Исключение
		Лог.Ошибка(Конфигуратор.ВыводКоманды());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

КонецФункции

Лог = Логирование.ПолучитьЛог("vanessa.app.deployka");