var EsCon = {
	lang: {
		langId: "{$smarty.session.lang.langId}",
		thousands: "{$smarty.session.lang.thousands}",
		decimal: "{$smarty.session.lang.decimal}",
		currencySymbol: "{$smarty.session.lang.currencySymbol}",
		dateSep: "{$smarty.session.lang.dateSep}",
	},

	inputEvent: {
		change: function(e) {
			var $this = $(this);
			var format = $this.attr('data-type');
			var hide_zero = $this.attr('data-hide_zero');

			if (format == 'Date') {
				var value = $this.val();
				// Ако е празно, просто записваме null
				if (!value)
					value = null;
				else {
					value = EsCon.parseDate(value);
					// Ако след проверката е null, значи е грешно
					if (!value)
						$this.addClass('isnan');
					else
						$this.removeClass('isnan');
					$this.val(EsCon.formatDate(value));
				}
			}
			else if (format == 'Time') {
				var value = $this.val();
				// Ако е празно, просто записваме null
				if (!value)
					value = null;
				else {
					value = EsCon.parseTime(value);
					// Ако след проверката е null, значи е грешно
					if (!value)
						$this.addClass('isnan');
					else
						$this.removeClass('isnan');
					$this.val(EsCon.formatTime(value));
				}
			}
			else {
				var value = EsCon.getFloatVal($this);
				if (isNaN(value)) {
					$this.addClass('isnan');
				} else {
					$this.removeClass('isnan');

					if (hide_zero && !parseFloat(value))
						$this.val('');
					else
					if (format == 'Currency')
						$this.val(EsCon.formatCurrency(value));
					else
					if (format == 'CurrencyBig')
						$this.val(EsCon.formatCurrencyBig(value));
					else
					if (format == 'Percent')
						$this.val(EsCon.formatPercent(value));
					else
					if (format == 'Percent3')
						$this.val(EsCon.formatPercent3(value));
					else
					if (format == 'Number0')
						$this.val(EsCon.format0(value));
					else
					if (format == 'Number2')
						$this.val(EsCon.format2(value));
					else
					if (format == 'Number3')
						$this.val(EsCon.format3(value));
				}
			}
		},
		keydown: function(e) {
		},
		focusin: function(e) {
			$(this).select();
		},
	},

	formatNumber: function(data) {
		return data.replace('.', EsCon.lang.decimal).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1'+EsCon.lang.thousands);
	},

	// Прави всички простотии и накрая връща форматирания string
	// data: string | number
	// type: string - по подразбиране е 'display'
	// Тъй като се предполага, че се вика само тука, то add_sign: string, decimals: integer, no_zero: boolean нямат подразбиращи се стойности
	formatInternal: function(data, type, add_sign, decimals, no_zero) {
		if (typeof(type) === 'undefined') type = 'display';
		if (type !== 'display') return data;
		if (typeof(data) === 'number') {
			if (isNaN(data)) return '';
			data = data.toFixed(decimals);
		}
		else {
			// Ако трябва да се клъцнат стотинките
			//if (decimals === 0) data = parseFloat(data).toFixed(0);
			data = parseFloat(data);
			if (isNaN(data)) data = 0;
			data = data.toFixed(decimals);
		}

		if (add_sign !== '')
			add_sign = ' '+add_sign;
		if (!no_zero)
			return EsCon.formatNumber(data)+add_sign;
		else
		if (parseFloat(data))
			return EsCon.formatNumber(data)+add_sign;
		else
			return '';
	},

	formatCurrency: function(data, type) {
		return EsCon.formatInternal(data, type, EsCon.lang.currencySymbol, 2, false);
	},
	formatCurrencyHideZero: function(data, type) {
		return EsCon.formatInternal(data, type, EsCon.lang.currencySymbol, 2, true);
	},

	formatCurrencyBig: function(data, type) {
		return EsCon.formatInternal(data, type, EsCon.lang.currencySymbol, 0, false);
	},
	formatCurrencyBigHideZero: function(data, type) {
		return EsCon.formatInternal(data, type, EsCon.lang.currencySymbol, 0, true);
	},

	formatPercent: function(data, type) {
		return EsCon.formatInternal(data, type, '%', 2, false);
	},
	formatPercentHideZero: function(data, type) {
		return EsCon.formatInternal(data, type, '%', 2, true);
	},

	formatPercent3: function(data, type) {
		return EsCon.formatInternal(data, type, '%', 3, false);
	},
	formatPercent3HideZero: function(data, type) {
		return EsCon.formatInternal(data, type, '%', 3, true);
	},

	format0: function(data, type) {
		return EsCon.formatInternal(data, type, '', 0, false);
	},
	format0HideZero: function(data, type) {
		return EsCon.formatInternal(data, type, '', 0, true);
	},
	format1: function(data, type) {
		return EsCon.formatInternal(data, type, '', 1, false);
	},
	format1HideZero: function(data, type) {
		return EsCon.formatInternal(data, type, '', 1, true);
	},
	format2: function(data, type) {
		return EsCon.formatInternal(data, type, '', 2, false);
	},
	format2HideZero: function(data, type) {
		return EsCon.formatInternal(data, type, '', 2, true);
	},
	format3: function(data, type) {
		return EsCon.formatInternal(data, type, '', 3, false);
	},
	format3HideZero: function(data, type) {
		return EsCon.formatInternal(data, type, '', 3, true);
	},

	formatInteger: function(data, type) {
		if (typeof(type) === 'undefined') type = 'display';
		if (type !== 'display') return data;
		if (typeof(data) === 'number') {
			if (isNaN(data)) return '';
			data = data.toFixed(0);
		}
		else {
			data = parseFloat(data);
			if (isNaN(data)) return '';
			data = data.toFixed(0);
		}
		return data;
	},
	formatIntegerHideZero: function(data, type) {
		if (typeof(type) === 'undefined') type = 'display';
		if (type !== 'display') return data;
		data = EsCon.formatInteger(data, type);
		if (parseInt(data))
			return data;
		else
			return '';
	},


	// От форматирания string да направим нормално число
	// Предполага се че само в input Currency има допълнителен символ. В останалите input Number няма допълнително добавени символи
	parseNumber: function(string) {
		if (typeof string === "number") return string;
		/*
		// Изтриваме всички символи освен цифри, EsCon.lang.decimal и "-"
		// string.replace(/[^0-9.-]/g, '')
		var re = new RegExp('[^0-9'+EsCon.lang.decimal+'-]', 'g');
		string = string.replace(re, '');
		// Заменям EsCon.lang.decimal със "."
		string = string.replace(EsCon.lang.decimal, '.');
		*/
		// Изтривам разделителя за хиляди, символа за валута, празните интервали
		var re = new RegExp('[\\s'+EsCon.lang.thousands+EsCon.lang.currencySymbol+']', 'g');
		string = string.replace(re, '')
			// Заменям EsCon.lang.decimal със "."
			.replace(EsCon.lang.decimal, '.');
		// Ако е останало нещо друго освен 0-9.- значи не е добро число
		// Идеята е да си остане непроменено на екрана както са го въвели, ако не е точно число

		if (string !== string.replace(/[^0-9.-]/g, ''))
			return '';
		else
			return string;
	},

	// Връща Float стойност от подадения форматиран jQuery $element
	// Връща NaN, ако има проблем с числото
	getFloatVal: function($element) {
		var format = $element.attr('data-type');
		if (format)
			return parseFloat(EsCon.parseNumber($element.val()));
		else
			return parseFloat($element.val());
	},

	formatDate: function(data, type) {
	// Конвертира 2015-05-24 към 24.05.2015
		if (typeof(type) === 'undefined') type = 'display';
		if (type !== 'display') return data;
//console.log(data, typeof(data));
		if (!data) return '';
		if (data == 'null') return '';

		// Ако е подадено тип Date, а не стринг
		if (data instanceof Date)
			data = [
				data.getFullYear(),
				data.getMonth() + 1,
				data.getDate()
			].map(function (i) { return i < 10 ? "0" + i : String(i); }).join("-") + ' ' +
			[
				data.getHours(),
				data.getMinutes(),
				data.getSeconds()
			].map(function (i) { return i < 10 ? "0" + i : String(i); }).join(":");

		// Ако е 0000-00-00 00:00
		var posSpace = data.indexOf(" ");
		if (posSpace > 0) {
			var t = data.substr(posSpace+1);
			// Само час и минути
			t = ' '+t.substr(0, 5);
			data = data.substr(0, posSpace);
		} else
			t = '';
		var d = data.split('-');
		return d[2]+EsCon.lang.dateSep+d[1]+EsCon.lang.dateSep+d[0]+t;
	},
	// Форматира cr_date, като добавя необходимите часове според часовата зона. cr_date е в UTC time
	formatCRDate: function(data, type) {
		// Конвертира 2015-05-24 08:15:35 към 24.05.2015 10:15
		if (typeof(type) === 'undefined') type = 'display';
		if (type !== 'display') return data;
		if (!data || data == 'null') return '';

		// От подадената дата правим Date, добавяме getTimezoneOffset(), правим string, форматираме
		//var _date = new Date(data.replace(/-/g, "/"));
		var _date = new Date(data.replace(/ /g, "T"));
		_date = _date.getTime() - (_date.getTimezoneOffset() * 60000);
		var newDateWithOffset = new Date(_date);
		return EsCon.formatDate(newDateWithOffset);
	},

	formatTime: function(data, type) {
		// Конвертира 00:00:00 към 00:00 - т.е. реже секундите
		if (typeof(type) === 'undefined') type = 'display';
		if (type !== 'display') return data;
		if (!data) return '';
		if (data == 'null') return '';

		// Само час и минути
		return data.substr(0, 5);
	},

	// Конвертира 24.05.2015 към 2015-05-24
	// Връща null, ако не е валидна дата
	parseDate: function(string) {
		if (string) {
			// Ако е 0000-00-00 00:00
			var posSpace = string.indexOf(" ");
			var t = '';
			if (posSpace > 0) {
				t = string.substr(posSpace+1);
				// Само час и минути
				t = ' '+t.substr(0, 5);
				string = string.substr(0, posSpace);
			}
			var d = string.split(EsCon.lang.dateSep);

			// Проба за допълване до Месец и Година
			var currentTime = new Date();
			if (d.length == 1) {
				d[2] = currentTime.getFullYear();
				d[1] = currentTime.getMonth() + 1;
				if (d[1].length == 1) d[1] = '0'+d[1];
			} else
			if (d.length == 2) {
				d[2] = currentTime.getFullYear();
			}
			if (d[2].length == 2)
				if (d[2] < '60')
					d[2] = '20'+d[2];
				else
					d[2] = '19'+d[2];

			var s = d[2]+"-"+d[1]+"-"+d[0]+t;
			// Ако не е валидна дата, направо връщаме null
			if (isNaN(Date.parse(s)))
				return null;
			else
				return s;
		}
		else
			return null;
	},
	parseTime: function(string) {
		if (string) {
			var d = string.split(':');

			if (d.length == 0) {
				d[0] = string;
				d[1] = '00';
			} else
			if (d.length == 1) {
				d[1] = '00';
			}
			if (d[0].length == 1) d[0] = '0'+d[0];
			if (d[1].length == 1) d[1] = '0'+d[1];
			d[0] = d[0].substr(0, 2);
			d[1] = d[1].substr(0, 2);

			var s = d[0]+":"+d[1];
			// Ако не е валидна дата, направо връщаме null
			if (isNaN(Date.parse('2016-12-12T'+s)))
				return null;
			else
				return s;
		}
		else
			return null;
	},


	// Връща разформатирана стойността от подадения jQuery $element като стринг
	// Ако числото се получи NaN, то се връща 0 с колкото трябва .00
	// Ако датата е null, то се връща '' само ако е подадено keep_null_in_date = false
	getParsedVal: function($element, keep_null_in_date) {
		var format = $element.attr('data-type');
		var value = $element.val();
		if (format == 'Date') {
			// Ако е празно, просто записваме null
			if (!value) {
				if (typeof(keep_null_in_date) === 'undefined') keep_null_in_date = true;
				if (keep_null_in_date)
					value = null;
				else
					value = '';
			} else
				value = EsCon.parseDate(value);
		}
		else if (format == 'Time') {
			// Ако е празно, просто записваме null
			if (!value) {
				if (typeof(keep_null_in_date) === 'undefined') keep_null_in_date = true;
				if (keep_null_in_date)
					value = null;
				else
					value = '';
			} else
				value = EsCon.parseTime(value);
		}
		else if (format) {
			value = EsCon.parseNumber(value);
			value = parseFloat(value);
			if (isNaN(value))
				value = 0;

			if (format == 'Currency')
				value = value.toFixed(2);
			else
			if (format == 'Percent')
				value = value.toFixed(2);
			else
			if (format == 'Percent3')
				value = value.toFixed(3);
			else
			if (format == 'Number0')
				value = value.toFixed(0);
			else
			if (format == 'Number2')
				value = value.toFixed(2);
			else
			if (format == 'Number3')
				value = value.toFixed(3);
			else
				value = value.toFixed(0);
		}
		return value;
	},


	// Това се прилага само за показаните със smarty променливи стойности в #edit, но не и за показаните с рендер функции в таблиците
	set_datepicker: function(selector, context) {
		if (typeof(selector)==='undefined') selector = 'input.date';
		if (typeof(context)==='undefined') context = '#edit';
		$(selector, context).not('.hasDatepicker').each(function() {
			// Заради WebKit Browsers and Back / Forward
			//var d = EsCon.formatDate($(this).val());
			var d = EsCon.formatDate($(this).attr('value'));
//console.log($(this).attr('value'), $(this).val(), d);
			$(this).val(d);
			if (!$(this).hasClass('readonly'))
				$(this).datepicker();
		});
	},
	
	// Това се прилага само за показаните със smarty променливи стойности в #edit, но не и за показаните с рендер функции в таблиците
	set_number_val: function($elements) {
		$elements.each(function() {
			var $this = $(this);
			var format = $this.attr('data-type');
			//var value = $this.val();
			var value = $this.attr('value');
			if (format == 'Currency')
				$this.val(EsCon.formatCurrency(value));
			else
			if (format == 'CurrencyBig')
				$this.val(EsCon.formatCurrencyBig(value));
			else
			if (format == 'Percent')
				$this.val(EsCon.formatPercent(value));
			else
			if (format == 'Percent3')
				$this.val(EsCon.formatPercent3(value));
			else
			if (format == 'Number0')
				$this.val(EsCon.format0(value));
			else
			if (format == 'Number2')
				$this.val(EsCon.format2(value));
			else
			if (format == 'Number3')
				$this.val(EsCon.format3(value));
			else
			if (format == 'Time')
				$this.val(EsCon.formatTime(value));
		});
	},

	// Да сложим attr placeholder на всички с .mandatory
	set_mandatory: function($elements) {
		$elements.not('.hasMandatory').each( function() {
			$this = $(this);
			$this.addClass("hasMandatory");
			if (this.nodeName.toLowerCase() === 'select') {
				// Да сложим текст за option value="0"
				// Ма само ако нямам -1
				var $disabled = $('option[value="-1"]', $this);
				if (!$disabled.length) {
					$disabled = $('option[value="0"]', $this);
					if ($disabled.length) {
						$disabled.attr('disabled', true).html("{#placeholder_required#}");
						$this.trigger("chosen:updated");
					}
					else {
						$disabled = $('option[value=""]', $this);
						if ($disabled.length) {
							$disabled.attr('disabled', true).html("{#placeholder_required#}");
							$this.trigger("chosen:updated");
						}
					}
				}
				$this.change(function () {
					if (Number($(this).val()) == 0)
						$(this).addClass("mandatory-empty");
					else
						$(this).removeClass("mandatory-empty");
				});
				if (Number($this.val()) == 0)
					$this.addClass("mandatory-empty");
				else
					$this.removeClass("mandatory-empty")
			} else
				$this.attr('placeholder', "{#placeholder_required#}");
		});
	},

	// Проверка за попълнени задължително полета
	check_mandatory: function($elements) {
		var isOK = true;
		$elements.each( function() {
			// Ако a е select от class hasChosen
			if ($(this).hasClass('hasChosen')) {
				$(this).data("chosen").selected_item.removeClass('isRequired');
			}
			else
				$(this).removeClass('isRequired');
		});
		$elements.each( function() {
			if (this.nodeName.toLowerCase() === 'select') {
				if (!checkRequiredSelect(this)) return (isOK = false);
			} else {
				if (!checkRequired(this)) return (isOK = false);
			}
		});
		return isOK;
	},

	// Имитиране на jQuery.serialize() през jQuery.serializeArray() от jquery-1.11.3.js ред 3998
	serialize: function($elements) {
		var Qb = /%20/g,
			Rb = /\[\]$/,
			Sb = /\r?\n/g,
			Tb = /^(?:submit|button|image|reset|file)$/i,
			Ub = /^(?:input|select|textarea|keygen)/i,
			W = /^(?:checkbox|radio)$/i;
		return $.param($elements.map(function () {
			var a = $.prop(this, "elements");
			return a ? $.makeArray(a) : this
		}).filter(function () {
			var a = this.type;
			return this.name && !$(this).is(":disabled") && Ub.test(this.nodeName) && !Tb.test(a) && (this.checked || !W.test(a))
		}).map(function (a, b) {
			// !!! Те тука трябва да се конвертира стойността !!!
			var c = EsCon.getParsedVal($(this), false);

			return null == c ? null : $.isArray(c) ? $.map(c, function (a) {
				return {
					name: b.name,
					value: a.replace(Sb, "\r\n")
				}
			}) : {
				name: b.name,
				value: c.replace(Sb, "\r\n")
			}
		}).get() );
	},

	
	// Функции за стандартно показване на данни в таблици
	renderUploadedFile: function( file_name, upfile_id ) {
		if ( file_name )
			return '<a rel="/uploads/file_display/'+upfile_id+'/'+file_name+'" onclick="clickOpenFile(this.rel)" style="cursor: pointer;" title="'+file_name+'">'
							+ displayDIV100('<img style="vertical-align: middle;" src="/images/document-16.png" alt="" border="0">')
						+ '</a>'
		else
			return displayDIV100('');
	},
	
	
}