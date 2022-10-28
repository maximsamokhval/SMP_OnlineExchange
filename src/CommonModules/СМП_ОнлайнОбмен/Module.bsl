////////////////////////////////////////////////////////////////////////////////
// <Заголовок модуля: краткое описание и условия применения модуля.>
//  
////////////////////////////////////////////////////////////////////////////////
#Область ПрограммныйИнтерфейс

// Возвращает учетную запись обмена по переданному идентификатору.
//
// Параметры:
//   ИдентификаторОбмена - Строка - набор символов однозначно идентифицирующий учетную запись обмена в базе-приемнике.
//   ЭтоПриемник - Булево - признак учетной записи обмена на стороне применика.
//
// Возвращаемое значение:
//   СправочникСсылка.СМП_УчетныеЗаписиОбменов, Неопределено
//
Функция ПолучитьУчетнуюЗаписьОбменаПоИд(ИдентификаторОбмена, ЭтоПриемник = Ложь) Экспорт
	
	УчетнаяЗапись = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УчетныеЗаписиОбменов.Ссылка КАК УчетнаяЗапись
	|ИЗ
	|	Справочник.СМП_УчетныеЗаписиОбменов КАК УчетныеЗаписиОбменов
	|ГДЕ
	|	УчетныеЗаписиОбменов.ПометкаУдаления = ЛОЖЬ
	|	И УчетныеЗаписиОбменов.ИдентификаторОбмена = &ИдентификаторОбмена
	|	И УчетныеЗаписиОбменов.НастройкаОбмена = &НастройкаОбмена
	|";
	
	Запрос.УстановитьПараметр("ИдентификаторОбмена", ИдентификаторОбмена);
	Запрос.УстановитьПараметр("НастройкаОбмена", 
	?(ЭтоПриемник, Перечисления.СМП_НастройкиОбменов.ДляПолучения, Перечисления.СМП_НастройкиОбменов.ДляОтправки));
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		УчетнаяЗапись = Выборка.УчетнаяЗапись;
	КонецЕсли;
	
	Возврат УчетнаяЗапись;
	
КонецФункции // ПолучитьУчетнуюЗаписьОбменаПоИд

// Возвращает описание правил конвертации в формате JSON.
//
// Параметры:
//   ИдентификаторОбмена - Строка - набор символов однозначно идентифицирующий учетную запись обмена в базе-приемнике.
//
// Возвращаемое значение:
//   Строка, Неопределено - строка с описанием правил конвертации в формате JSON
//
Функция ПолучитьОписаниеПравилКонвертации(ИдентификаторОбмена) Экспорт
	
	ОписаниеВыгружаемыхДанных = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СМП_УчетныеЗаписиОбменов.ОписаниеВыгружаемыхДанных КАК ОписаниеВыгружаемыхДанных
	|ИЗ
	|	Справочник.СМП_УчетныеЗаписиОбменов КАК СМП_УчетныеЗаписиОбменов
	|ГДЕ
	|	СМП_УчетныеЗаписиОбменов.ПометкаУдаления = ЛОЖЬ
	|	И СМП_УчетныеЗаписиОбменов.ИдентификаторОбмена = &ИдентификаторОбмена
	|	И СМП_УчетныеЗаписиОбменов.НастройкаОбмена = ЗНАЧЕНИЕ(Перечисление.СМП_НастройкиОбменов.ДляПолучения)";
	
	Запрос.УстановитьПараметр("ИдентификаторОбмена", ИдентификаторОбмена);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		ОписаниеВыгружаемыхДанных = Выборка.ОписаниеВыгружаемыхДанных;
	КонецЕсли;
	
	
	Возврат ОписаниеВыгружаемыхДанных;
	
КонецФункции // ПолучитьОписаниеПравилКонвертации

// Возвращает настройки транспорта обмена данными.
//
// Параметры:
//   УчетнаяЗапись - СправочникСсылка.СМП_УчетныеЗаписиОбменов - обмен для которого нужно получить настройки.
//
// Возвращаемое значение:
//   Структура:
//		* Ключ - имя настройки
//		* Значение - значение настройки
//
Функция ПолучитьНастройкиТранспортаОбменаДанными(УчетнаяЗапись) Экспорт
	
	ИменаПолей = Новый Структура("ИдентификаторОбмена, ВидТранспорта, ИнтернетАдрес, КаталогФайлов, ИмяСервера1С, ИмяБазы, ИмяПользователя, ПарольПользователя",
	"ИдентификаторОбмена",
	"СпособПодключения",
	"ХттпСервисАдресПодключения",
	"ФайлКаталогОбмена",
	"КомИмяСервера1СПредприятия",
	"КомИмяИнформационнойБазыНаСервере1СПредприятия",
	"ИмяПользователя",
	"ПарольПользователя");
	НастройкиТранспорта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(УчетнаяЗапись, ИменаПолей);
	
	Возврат НастройкиТранспорта;
	
КонецФункции // ПолучитьНастройкиТранспортаОбменаДанными

// Возвращает строку в формате JSON с данными элемента справочника или документа
// полученными по ссылке.
//
// Параметры:
//   ДанныеСсылка - СправочникСсылка, ДокументСсылка - ссылка по которой нужно получить данные.
//   УчетнаяЗаписьОбмена - СправочникСсылка.СМП_УчетныеЗаписиОбменов - обмен для которого выполняется сериализация данных.
//   ТолькоСсылки - Булево - Признак полной или частичной конвертации объекта (потом убрать).
//
// Возвращаемое значение:
//   Строка - Строка в формате JSON с данными элемента справочника или документа.
//
Функция ДанныеПоСсылкеВJSON(ДанныеСсылка, УчетнаяЗаписьОбмена, ТолькоСсылки = Истина) Экспорт
	
	Конвертер = Обработки.СМП_JSONКонвертер.Создать();
	Конвертер.УчетнаяЗаписьОбмена = УчетнаяЗаписьОбмена;
	Конвертер.ЗаполнитьОписаниеВыгружаемыхТиповДанных();
	Конвертер.ОсновнойОбъектСсылка = ДанныеСсылка;
	МассивJSON = Конвертер.ПолучитьМассивСериализованныхОбъектов();
	
	Возврат МассивJSON;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Формирует и отправляет исходящие сообщения на основании данных с очереди обработки.
//
// Параметры:
//   ИдентификаторПользователяИБ - Строка - см. СМП_ОнлайнОбменПовтИсп.ПолучитьИдентификаторТекущегоПользователяИБ()
//   УчетнаяЗаписьОбмена - СправочникСсылка.СМП_УчетныеЗаписиОбменов - обмен данными, в рамках которого выполняется отправка сообщений.
//   ИдентификаторСообщения - Строка - строковое представление укального идентификатора конкретного сообщения.
//   СтатусСообщения - ПеречислениеСсылка.СМП_СтатусыОбработкиСообщений - статус обрабатываемых сообщений.
//   ВызовИзСписка - Булево - признак вызова процедуры из формы списка очереди (обработка конктретного сообщения)
//
Процедура СформироватьОтправитьИсходящиеСообщения(ИдентификаторПользователяИБ = Неопределено, 
												  УчетнаяЗаписьОбмена = Неопределено, 
												  ИдентификаторСообщения = Неопределено, 
												  СтатусСообщения = Неопределено,
												  ВызовИзСписка = Ложь) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СМП_ОчередьОбработкиДанных.ИдентификаторПользователяИБ КАК ИдентификаторПользователяИБ,
	|	СМП_ОчередьОбработкиДанных.УчетнаяЗаписьОбмена КАК УчетнаяЗаписьОбмена,
	|	СМП_ОчередьОбработкиДанных.УникальныйИдентификатор КАК УникальныйИдентификатор,
	|	СМП_ОчередьОбработкиДанных.ТаймШтамп КАК ТаймШтамп,
	|	СМП_ОчередьОбработкиДанных.Данные КАК Данные
	|ИЗ
	|	РегистрСведений.СМП_ОчередьОбработкиДанных КАК СМП_ОчередьОбработкиДанных
	|ГДЕ
	|	ИСТИНА
	|
	|УПОРЯДОЧИТЬ ПО
	|	ТаймШтамп";
	
	ЧастьУсловия = "";
	Если ИдентификаторПользователяИБ <> Неопределено Тогда
		ЧастьУсловия = "СМП_ОчередьОбработкиДанных.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";
		Запрос.УстановитьПараметр("ИдентификаторПользователяИБ", ИдентификаторПользователяИБ);
	КонецЕсли;
	
	Если УчетнаяЗаписьОбмена <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьОбработкиДанных.УчетнаяЗаписьОбмена = &УчетнаяЗаписьОбмена";
		Запрос.УстановитьПараметр("УчетнаяЗаписьОбмена", УчетнаяЗаписьОбмена);
	КонецЕсли;
	
	Если ИдентификаторСообщения <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьОбработкиДанных.УникальныйИдентификатор = &УникальныйИдентификатор";
		Запрос.УстановитьПараметр("УникальныйИдентификатор", ИдентификаторСообщения);
	КонецЕсли;
	
	Если СтатусСообщения <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьОбработкиДанных.Статус = &Статус";
		Запрос.УстановитьПараметр("Статус", СтатусСообщения);
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ЧастьУсловия) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИСТИНА", ЧастьУсловия);
	КонецЕсли;
	
	Пока Истина Цикл
		
		Результат = Запрос.Выполнить();
		
		Если Результат.Пустой() Тогда
			Прервать;
		Иначе
			
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				
				ВключенаОтладка = СМП_ОнлайнОбменПовтИсп.ВключенаОтладкаДляОбмена(Выборка.УчетнаяЗаписьОбмена);
				
				СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусВОбработке(Выборка.УникальныйИдентификатор);
				
				Попытка
					
					ОбъектОчереди = ЗначениеИзСтрокиВнутр(Выборка.Данные);
					МассивИсходящихСообщений = ДанныеПоСсылкеВJSON(ОбъектОчереди, Выборка.УчетнаяЗаписьОбмена, Истина);
					
					Для Каждого исхСообщение Из МассивИсходящихСообщений Цикл
						СМП_ОнлайнОбменУправлениеОчередями.ДобавитьСообщениеВОчередьИсходящих(
							Выборка.ИдентификаторПользователяИБ, Выборка.УчетнаяЗаписьОбмена, исхСообщение);
					КонецЦикла;
					
					Если ВключенаОтладка Тогда
						СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусОбработано(Выборка.УникальныйИдентификатор);
					Иначе
						СМП_ОнлайнОбменУправлениеОчередями.УдалитьСообщениеИзОчереди(Выборка.УникальныйИдентификатор);
					КонецЕсли;
					
					ВыполнитьОтправкуИсходящихСообщений(Выборка.ИдентификаторПользователяИБ, Выборка.УчетнаяЗаписьОбмена, , 
						Перечисления.СМП_СтатусыОбработкиСообщений.Новое, ВключенаОтладка, ВызовИзСписка);
					
				Исключение
					
					ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
					СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусОшибкаОбработки(Выборка.УникальныйИдентификатор, , ТекстОшибки);
					
				КонецПопытки;
				
			КонецЦикла;
		КонецЕсли;
		
		Если ВызовИзСписка Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры //СформироватьОтправитьИсходящиеСообщения

// Отправляет подготовленные исходящие сообщения.
//
// Параметры:
//   ИдентификаторПользователяИБ - Строка - см. СМП_ОнлайнОбменПовтИсп.ПолучитьИдентификаторТекущегоПользователяИБ()
//   УчетнаяЗаписьОбмена - СправочникСсылка.СМП_УчетныеЗаписиОбменов - обмен данными, в рамках которого выполняется отправка сообщений.
//   ИдентификаторСообщения - Строка - строковое представление уникального идентификатора конкретного сообщения.
//   СтатусСообщения - ПеречислениеСсылка.СМП_СтатусыОбработкиСообщений - статус обрабатываемых сообщений.
//   ВключенаОтладка - Булево
//   ВызовИзСписка - Булево - признак вызова процедуры из формы списка очереди (обработка конктретного сообщения)
//
Процедура ВыполнитьОтправкуИсходящихСообщений(ИдентификаторПользователяИБ = Неопределено, 
											  УчетнаяЗаписьОбмена = Неопределено, 
											  ИдентификаторСообщения = Неопределено, 
											  СтатусСообщения = Неопределено,
											  ВключенаОтладка = Неопределено,
											  ВызовИзСписка = Ложь) Экспорт
	
	Если ВключенаОтладка = Неопределено Тогда
		ВключенаОтладка = СМП_ОнлайнОбменПовтИсп.ВключенаОтладкаДляОбмена(УчетнаяЗаписьОбмена);
	КонецЕсли;
	
	НастройкиТранспорта = СМП_ОнлайнОбменПовтИсп.ПолучитьНастройкиТранспортаОбменаДанными(УчетнаяЗаписьОбмена);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СМП_ОчередьИсходящихСообщений.ИдентификаторПользователяИБ КАК ИдентификаторПользователяИБ,
	|	СМП_ОчередьИсходящихСообщений.УчетнаяЗаписьОбмена КАК УчетнаяЗаписьОбмена,
	|	СМП_ОчередьИсходящихСообщений.УникальныйИдентификатор КАК УникальныйИдентификатор,
	|	СМП_ОчередьИсходящихСообщений.ТаймШтамп КАК ТаймШтамп,
	|	СМП_ОчередьИсходящихСообщений.Статус КАК Статус,
	|	СМП_ОчередьИсходящихСообщений.Данные КАК Данные,
	|	СМП_ОчередьИсходящихСообщений.ДатаДобавления КАК ДатаДобавления,
	|	СМП_ОчередьИсходящихСообщений.СообщениеОбОшибке КАК СообщениеОбОшибке,
	|	СМП_ОчередьИсходящихСообщений.ДатаОбработки КАК ДатаОбработки
	|ИЗ
	|	РегистрСведений.СМП_ОчередьИсходящихСообщений КАК СМП_ОчередьИсходящихСообщений
	|ГДЕ
	|	ИСТИНА
	|
	|УПОРЯДОЧИТЬ ПО
	|	ТаймШтамп";
	
	ЧастьУсловия = "";
	Если ИдентификаторПользователяИБ <> Неопределено Тогда
		ЧастьУсловия = "СМП_ОчередьИсходящихСообщений.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";
		Запрос.УстановитьПараметр("ИдентификаторПользователяИБ", ИдентификаторПользователяИБ);
	КонецЕсли;
	
	Если УчетнаяЗаписьОбмена <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьИсходящихСообщений.УчетнаяЗаписьОбмена = &УчетнаяЗаписьОбмена";
		Запрос.УстановитьПараметр("УчетнаяЗаписьОбмена", УчетнаяЗаписьОбмена);
	КонецЕсли;
	
	Если ИдентификаторСообщения <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьИсходящихСообщений.УникальныйИдентификатор = &УникальныйИдентификатор";
		Запрос.УстановитьПараметр("УникальныйИдентификатор", ИдентификаторСообщения);
	КонецЕсли;
	
	Если СтатусСообщения <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьИсходящихСообщений.Статус = &Статус";
		Запрос.УстановитьПараметр("Статус", СтатусСообщения);
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ЧастьУсловия) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИСТИНА", ЧастьУсловия);
	КонецЕсли;
	
	Пока Истина Цикл
		
		Результат = Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			Прервать;
		Иначе
			
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				
				СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусВОбработке(Выборка.УникальныйИдентификатор, "исход");
				РезультатОтправки = СМП_ОнлайнОбменСобытия.ОтправитьИсходящееСообщение(НастройкиТранспорта, Выборка.Данные);
				
				Если РезультатОтправки.Успешно = Истина Тогда
					
					Если ВключенаОтладка Тогда
						СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусДоставлено(Выборка.УникальныйИдентификатор, "исход");
					Иначе
						СМП_ОнлайнОбменУправлениеОчередями.УдалитьСообщениеИзОчереди(Выборка.УникальныйИдентификатор, "исход");
					КонецЕсли;
					
				Иначе
					
					СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусОшибкаОбработки(Выборка.УникальныйИдентификатор, "исход", РезультатОтправки.ТекстОшибки);
					
				КонецЕсли;
				
			КонецЦикла;
		КонецЕсли;
		
		Если ВызовИзСписка Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры //ВыполнитьОтправкуИсходящихСообщений

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Обрабатывает принятые сообщения.
//
// Параметры:
//   ИдентификаторПользователяИБ - Строка - см. СМП_ОнлайнОбменПовтИсп.ПолучитьИдентификаторТекущегоПользователяИБ()
//   УчетнаяЗаписьОбмена - СправочникСсылка.СМП_УчетныеЗаписиОбменов - обмен данными, в рамках которого выполняется отправка сообщений.
//   ИдентификаторСообщения - Строка - строковое представление уникального идентификатора конкретного сообщения.
//   СтатусСообщения - ПеречислениеСсылка.СМП_СтатусыОбработкиСообщений - статус обрабатываемых сообщений.
//   ВызовИзСписка - Булево - признак вызова процедуры из формы списка очереди (обработка конктретного сообщения)
//
Процедура ОбработатьВходящиеСообщения(ИдентификаторПользователяИБ = Неопределено, 
									  УчетнаяЗаписьОбмена = Неопределено, 
									  ИдентификаторСообщения = Неопределено, 
									  СтатусСообщения = Неопределено, 
									  ВызовИзСписка = Ложь) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СМП_ОчередьВходящихСообщений.ИдентификаторПользователяИБ КАК ИдентификаторПользователяИБ,
	|	СМП_ОчередьВходящихСообщений.УчетнаяЗаписьОбмена КАК УчетнаяЗаписьОбмена,
	|	СМП_ОчередьВходящихСообщений.УникальныйИдентификатор КАК УникальныйИдентификатор,
	|	СМП_ОчередьВходящихСообщений.ТаймШтамп КАК ТаймШтамп,
	|	СМП_ОчередьВходящихСообщений.Статус КАК Статус,
	|	СМП_ОчередьВходящихСообщений.Данные КАК Данные,
	|	СМП_ОчередьВходящихСообщений.ДатаДобавления КАК ДатаДобавления,
	|	СМП_ОчередьВходящихСообщений.СообщениеОбОшибке КАК СообщениеОбОшибке,
	|	СМП_ОчередьВходящихСообщений.ДатаОбработки КАК ДатаОбработки
	|ИЗ
	|	РегистрСведений.СМП_ОчередьВходящихСообщений КАК СМП_ОчередьВходящихСообщений
	|ГДЕ
	|	ИСТИНА
	|
	|УПОРЯДОЧИТЬ ПО
	|	ТаймШтамп";
	
	ЧастьУсловия = "";
	Если ИдентификаторПользователяИБ <> Неопределено Тогда
		ЧастьУсловия = "СМП_ОчередьВходящихСообщений.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";
		Запрос.УстановитьПараметр("ИдентификаторПользователяИБ", ИдентификаторПользователяИБ);
	КонецЕсли;
	
	Если УчетнаяЗаписьОбмена <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьВходящихСообщений.УчетнаяЗаписьОбмена = &УчетнаяЗаписьОбмена";
		Запрос.УстановитьПараметр("УчетнаяЗаписьОбмена", УчетнаяЗаписьОбмена);
	КонецЕсли;
	
	Если ИдентификаторСообщения <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьВходящихСообщений.УникальныйИдентификатор = &УникальныйИдентификатор";
		Запрос.УстановитьПараметр("УникальныйИдентификатор", ИдентификаторСообщения);
	КонецЕсли;
	
	Если СтатусСообщения <> Неопределено Тогда
		ЧастьУсловия = ЧастьУсловия + ?(НЕ ПустаяСтрока(ЧастьУсловия), " И ", "") 
		+ "СМП_ОчередьВходящихСообщений.Статус = &Статус";
		Запрос.УстановитьПараметр("Статус", СтатусСообщения);
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ЧастьУсловия) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИСТИНА", ЧастьУсловия);
	КонецЕсли;
	
	Пока Истина Цикл
		
		Результат = Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			Прервать;
		Иначе
			
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				
				ОтладкаВключена = СМП_ОнлайнОбменПовтИсп.ВключенаОтладкаДляОбмена(Выборка.УчетнаяЗаписьОбмена);
				
				СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусВОбработке(Выборка.УникальныйИдентификатор, "вход");
				
				Попытка
					
					СМП_ОнлайнОбменСобытия.ОбработатьВходящееСообщение(Выборка.УчетнаяЗаписьОбмена, Выборка.Данные);
					
					Если ОтладкаВключена Тогда
						СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусОбработано(Выборка.УникальныйИдентификатор, "вход");
					Иначе
						СМП_ОнлайнОбменУправлениеОчередями.УдалитьСообщениеИзОчереди(Выборка.УникальныйИдентификатор, "вход");
					КонецЕсли;
					
				Исключение
					
					ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
					СМП_ОнлайнОбменУправлениеОчередями.УстановитьСтатусОшибкаОбработки(Выборка.УникальныйИдентификатор, "вход", ТекстОшибки);
					
				КонецПопытки;
			КонецЦикла;
		КонецЕсли;
		
		Если ВызовИзСписка Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры //ОбработатьВходящиеСообщения

#КонецОбласти
