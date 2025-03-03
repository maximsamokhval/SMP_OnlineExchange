
#Область ПрограммныйИнтерфейс

// Регистрирует выгрузку элементов справочника.
//
// Параметры:
//   УчетнаяЗаписьОбмена - СправочникСсылка.СМП_УчетныеЗаписиОбменов - учетная запись, в рамках которой выполняется обмен данными.
//   ЭлементСправочника - СправочникСсылка - ссылка на элемент выгружаемого справочника.
//
Процедура ЗарегистрироватьВыгрузкуЭлементовСправочников(УчетнаяЗаписьОбмена, ЭлементыСправочников) Экспорт
	
	НЗ = РегистрыСведений.СМП_ВыгруженныеСправочники.СоздатьНаборЗаписей();
	
	Для Каждого ДанныеСсылки Из ЭлементыСправочников Цикл
		
		СсылкаСтрокой = ЗначениеВСтрокуВнутр(ДанныеСсылки.Ключ);
		Запись = НЗ.Добавить();
		Запись.УчетнаяЗаписьОбмена = УчетнаяЗаписьОбмена;
		Запись.ЭлементСправочника = СсылкаСтрокой;
		
	КонецЦикла;
	
	НЗ.Записать(Ложь);
	
КонецПроцедуры //ЗарегистрироватьВыгрузкуЭлементаСправочника

// Проверяет выгружался ли раннее этот элемент справочника при обмене.
//
// Параметры:
//   ЭлементСправочника - СправочникСсылка - ссылка на проверяемый элемент справочника.
//
// Возвращаемое значение:
//   ВыборкаИзРезультатаЗапроса, Неопределено - выборка со списком учетных записей обмена данными 
//   по которым раннее выгружался элемент справочника.
//
Функция ПроверитьВыгрузкуЭлементаСправочника(ЭлементСправочника, УчетнаяЗаписьОбмена = Неопределено) Экспорт
	
	СсылкаСтрокой = ЗначениеВСтрокуВнутр(ЭлементСправочника);
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СМП_ВыгруженныеСправочники.УчетнаяЗаписьОбмена КАК УчетнаяЗаписьОбмена
	|ИЗ
	|	РегистрСведений.СМП_ВыгруженныеСправочники КАК СМП_ВыгруженныеСправочники
	|ГДЕ
	|	СМП_ВыгруженныеСправочники.ЭлементСправочника = &СсылкаСтрокой";
	
	Запрос.УстановитьПараметр("СсылкаСтрокой", СсылкаСтрокой);
	
	Если УчетнаяЗаписьОбмена <> Неопределено Тогда
		Запрос.Текст = Запрос.Текст + " И СМП_ВыгруженныеСправочники.УчетнаяЗаписьОбмена = &УчетнаяЗаписьОбмена";
		Запрос.УстановитьПараметр("УчетнаяЗаписьОбмена", УчетнаяЗаписьОбмена);
	КонецЕсли;
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Выборка = Результат.Выбрать();
		Возврат Выборка;
	КонецЕсли;
	
КонецФункции // ПроверитьВыгрузкуЭлементаСправочника


#КонецОбласти

#Область СлужебныеПроцедурыИФункции
// Код процедур и функций
#КонецОбласти

#Область Инициализация

#КонецОбласти