
	function get_today_ISO() {
		var d = new Date();
		var month = d.getMonth()+1;
		var day = d.getDate();
		return d.getFullYear() + '-' + (month<10 ? '0' : '') + month + '-' + (day<10 ? '0' : '') + day;
	}
	var today_ISO = get_today_ISO();

	// class="hover cell-border row-border stripe"
	dataTable_default_class = "hover cell-border";

	$.extend($.fn.DataTable.Buttons.defaults.dom.button, {
		tag: 'button',
		className: '',
		active: 'active',
		disabled: 'disabled'
	});
	$.extend( true, $.fn.dataTable.defaults, {
		// Ако scrollCollapse е false, височината на таблицата винаги е scrollY
		// иначе е колкото са редовете
		scrollCollapse: true,
		// Ако autoWidth e false, то не се изравняват колоните с footer, но само при scrollX
		autoWidth: false,

		paging: false,
		// pageLength да е точно преди номерата на страниците
		dom: 'frtlp',
		lengthMenu: [ [15, 20, 50, -1], [15, 20, 50, "All"] ],
		pageLength: 20,
		pagingType: "numbers",

		select: {
			items: 'row',
			//style: 'single',
			style: 'os',
		},

		deferRender: true,
		"processing": true,
		"language": {
			"loadingRecords": "Loading...",
			"processing": "Processing...",
			"lengthMenu": "Display _MENU_ records",
		},
		
		rowId: 'id',
		/*
		"createdRow": function( row, data, dataIndex ) {
			$(row).attr('id', 'id-'+data['id']);
		},
		*/

		colReorder: false,

		fixedHeader: {
			header: true,
		},

		info: false
	});
	// Disable initial sort on first column
	$.fn.dataTable.defaults.aaSorting = [];

	// This plugin permits to show the right page of DataTable to show the selected row
	// https://github.com/DataTables/Plugins/blob/master/api/row().show().js
	$.fn.dataTable.Api.register('row().show()', function() {
		var page_info = this.table().page.info();
		// Get row index
		var new_row_index = this.index();
		if (new_row_index === undefined)
			return this;
		// Row position
//var temp_start = Date.now();
		// Това е доста бавна операция
		//var row_position = this.table().rows()[0].indexOf( new_row_index );
		var row_position = this.table().rows().indexes().indexOf( new_row_index );
//console.log('row().show() row_position '+(Date.now() - temp_start));
		// Already on right page ?
		if( row_position >= page_info.start && row_position < page_info.end ) {
			// Return row object
			return this;
		}
		// Find page number
		var page_to_display = Math.floor( row_position / this.table().page.len() );
		// Go to that page
		this.table().page( page_to_display );
		// Return row object
		return this;
	});
	// https://github.com/DataTables/Plugins/blob/master/api/page.jumpToData().js
	// table.page.jumpToData( "Allan Jardine", 0 );
	$.fn.dataTable.Api.register( 'page.jumpToData()', function ( data, column ) {
		var pos = this.column(column, { order:'current' }).data().indexOf( data );

		if ( pos >= 0 ) {
			var page = Math.floor( pos / this.page.info().length );
			this.page( page ).draw( false );
		}

		return this;
	});

	// Глобални променливи за селектиране и опресняване на ред при редактиране през magnificPopup
	var oTable, edit_row, edit_id, edit_add_new = false, edit_delete = false;
	var is_edit_child = false;

	function selectClickedRow(el) {
		oTable.rows({ selected: true }).deselect();
		var edit_tr = $(el).parents("tr");
		oTable.row(edit_tr).select();
		edit_row = oTable.row(edit_tr);
		edit_id = edit_row.data().id;
	}

	function getSelectedRow() {
		// Кой е избрания запис - само първия
		edit_row = oTable.row('.selected');
		if (!edit_row.length) return false;
		edit_id = edit_row.data().id;
		return true;
	}



	$.extend( jQuery.magnificPopup.defaults, {
		preloader: false,
		//disableOn: 0,
		closeOnBgClick: false,
		enableEscapeKey: false,
		overflowY: 'scroll',
		//alignTop: true,

		callbacks: {
			afterClose: commonFancyboxAfterClose,
			parseAjax: function(data, status, jqXHR) {
				if (data.data.substr(0, 5) == '\<!DOC')
					this.close();
			},
			/*
			open: function() {
				// Ако ширината на .documentElmagnificPopup е > от екрана, да позиционирам вертикално Top
				// window.outerWidth - document.documentElement.clientWidth = ширината на scrollBar
				//console.log(document.documentElement.clientWidth, window.outerWidth , this.content.outerWidth());
				if (this.content.outerWidth() > 2*document.documentElement.clientWidth - window.outerWidth)
					this.wrap.addClass('mfp-align-top');
			},
			*/
		}
	});

	function commonFancyboxAfterClose() {
		// Изтриване на паразитните .dz-hidden-input, защото се натрупват с всяко отваряне
		$("body > .dz-hidden-input").remove();
	}

	function commonFancyboxSaved($url, $id, callbackSuccess) {
		$.ajax({
			type: 'GET',
			url: $url,
			success: function(result) {
				if (!result) return;
				try {
					var data = JSON.parse(result)
				} catch(err) {
					fnShowErrorMessage('', result);
					return;
				}
				if (!edit_row && !edit_add_new) return;
				try {
					if (!edit_add_new)
						edit_row.data(data);
					else
						edit_row = oTable.row.add(data);
					oTable.rows({ selected: true }).deselect();
					edit_row.select();
					edit_row.draw().show().draw(false);
					if (typeof callbackSuccess == 'function') callbackSuccess(edit_row);
				} catch(err) {
					fnShowErrorMessage('', err);
				}
			}
		});
	}

	function commonFancyboxDeleted(callbackSuccess) {
		// Ако се изтрива елемента от показаната таблица, ще премахнем реда от таблицата, иначе ще опресним реда
		if (edit_delete) {
			edit_row.remove().draw('page');
			if (typeof callbackSuccess == 'function') callbackSuccess(edit_row);
		}
		else
			if (typeof(fancyboxSaved) == 'function') fancyboxSaved();
	}

	function commonInitMFP(sub_selector, selector) {
		if (typeof (sub_selector) === 'undefined') sub_selector = "a[rel|=edit], button[rel|=edit]";
		if (typeof(selector)==='undefined') selector = "#main";
		// За номенклатурите
		$(selector).on('click', sub_selector, function(event) {
			event.preventDefault();
			event.stopImmediatePropagation();
			is_edit_child = false;

			$this = $(this);
			/*
			if (this.nodeName.toLowerCase() === 'button')
				$this = $this.children(':first');
			*/

			var url = $this.attr("url");
			if (!url)
				url = $this.attr("href");
			var a_rel = $this.attr("rel");

			// Дали е нов елемент, който после се добавя в таблицата
			if (a_rel == "edit-0") {
				// Ако има атрибут field_id, то стойността му трябва да се добави към url накрая, но само при нов
				var field_id = $this.attr('field_id')||'';
				if (field_id) {
					if (!getSelectedRow())
						url = '';
					else {
						var t_id = edit_row.data()[field_id];
						if (edit_id && t_id!=0) {
							url = url + '/'+t_id;
						} else
							url = '';
					}
				}
				// Дали е нов елемент, който после се добавя в таблицата
				edit_add_new = $this.is("[edit_add_new]") ? true : false;
				if (edit_add_new) {
					edit_row = null;
					edit_id = 0;
				}
				edit_delete = false;
			} else {
				selectClickedRow(this);
				edit_add_new = false;
				edit_delete = $this.is("[edit_delete]") ? true : false;
			}
			if (url === '') return;
			if ($this.attr("fullscreen"))
				window.location.href = url;
			else
				showMFP(url);
		});
	} // InitMFP

	function showMFP(url, post_data, focus_item) {
		if (typeof(post_data) === 'undefined') {
			type = 'GET';
			post_data = { };
		} else {
			type = 'POST';
		}
		if (typeof(focus_item)==='undefined') focus_item = '';
		$.ajax({
			type: type,
			url: url,
			data: post_data,
			success: function(html) {
				if (html.substr(1, 4) == '!DOC') {
					fnShowErrorMessage('', '{#access_denied#}');
					return false;
				}
				if (html.substr(0, 5) == 'Error') {
					fnShowErrorMessage('', html);
					return false;
				}
				//try {
					$.magnificPopup.open({
						items: { src: html },
						type: 'inline',
						focus: focus_item,
						preloader: true,
					});
				/*
				} catch(err) {
					fnShowErrorMessage('', err+'\n'+html);
				}
				*/
			}
		});
	}


	$.datepicker.setDefaults({
		/* - без бутон, направо с кликване в полето
		showOn: "button",
		buttonImageOnly: true,
		buttonImage: "/images/datepicker.gif",
		//buttonImage: "/images/iconDatePicker.gif",
		*/
		changeMonth: true,
		changeYear: true,
		yearRange: "c-5:c+5",
		showButtonPanel: true,

		//dateFormat: 'dd.mm.yy',
		firstDay: 1
	});


	var entityMap = {
		'&': '&amp;',
		'<': '&lt;',
		'>': '&gt;',
		'"': '&quot;',
		"'": '&#39;',
		'/': '&#x2F;',
		'`': '&#x60;',
		'=': '&#x3D;'
	};
	function escapeHtml (data) {
		if (!data) return '';
		if (data == '&nbsp;') return data;
		return String(data).replace(/[&<>"'`=\/]/g, function (s) {
			return entityMap[s];
		});
	}

	function checkRequired(a, field_caption, data_type) {
		// Ако не съществува selector a, излизаме
		if (!$(a).length) return true;
		// data_type == '', 'Date', 'Numeric'
		if (typeof (data_type) === 'undefined') data_type = '';
		if (typeof (field_caption) === 'undefined') {
			// Търсим Етикет. Първо предишния елемент
			var label = $(a).prev();
			if (label.length < 1)
				label = $(a).parent().prev();
			field_caption = label.html();
		}

		var isOK = true;
		if (!data_type) {
			var value = $(a).val();
			if (!value || value.length < 1)
				isOK = false;
		} else
		if (data_type == 'Numeric') {
			var value = Number(EsCon.getParsedVal($(a)));
			if (value === 0)
				isOK = false;
		} else
		if (data_type == 'Date') {
			var value = EsCon.getParsedVal($(a));
			if (!value)
				isOK = false;
		}

		if (!isOK) {
			// Ако a е select от class hasChosen
			if ($(a).hasClass('hasChosen')) {
				$(a).data("chosen").selected_item.addClass('isRequired');
			}
			else
				$(a).addClass('isRequired');
			fnShowErrorMessage('{#title_attention#}', '"' + field_caption + '" {#is_required#}!')
			return false;
		} else
			return true;
	}
	function checkRequiredNumeric(a, field_caption) {
		return checkRequired(a, field_caption, 'Numeric');
	}
	function checkRequiredDate(a, field_caption) {
		return checkRequired(a, field_caption, 'Date');
	}
	function checkRequiredSelect(a, field_caption) {
		return checkRequired(a, field_caption, 'Numeric');
	}



	// Изтриване на Номенклатура или Документ през Popup прозореца
	function fnDeleteDialog($delete_url, $table_name, error_prepend_elem, is_from_fancybox) {
		if (typeof(error_prepend_elem)==='undefined') error_prepend_elem = '#main';
		if (typeof(is_from_fancybox)==='undefined') is_from_fancybox = true;
		$("<div/>")
			.html('{#Delete_element#} "'+$table_name+'"')
			.dialog({
				modal: true,
				resizable: false,
				height: 150,
				//autoOpen: false,
				closeOnEscape: true,
				//dialogClass: "dlg-no-title",
				title: "{#Confirm#}",
				buttons: {
					"Yes": {
						"text": "{#btn_Yes#}",
						click: function() {
							$(this).dialog("close");
							//  Function( PlainObject result, String textStatus, jqXHR jqXHR )
							jQuery.post($delete_url, { 'process': 'delete' }, function (result, textStatus, jqXHR) {
								if (is_from_fancybox)
									($.magnificPopup.instance).close();

								if (result) {
									fnShowErrorMessage('', result);
								} else {
									// callback фукнция, намираща се във <table>.tpl - Тя опреснява реда в таблицата
									if (typeof(fancyboxDeleted) == 'function') fancyboxDeleted();
								}
							});
						},
						// ui-button ui-widget ui-corner-all ui-state-default 
						"class": 'save_button', 
					},
					"No": {
						"text": "{#btn_No#}",
						click: function() {
							$(this).dialog("close");
						},
						"class": 'cancel_button', 
					},
				},
				close: function(event, ui) {
					$(this).dialog('destroy');
				},
				create: function (event, ui) {
					$(this).closest(".ui-dialog").removeClass('ui-corner-all')
						.find(".ui-corner-all").removeClass('ui-corner-all').end()
						.find(".ui-dialog-buttonpane button").removeClass('ui-button ui-widget ui-state-default ui-state-active ui-state-focus')
						.mouseover(function() { $(this).removeClass('ui-state-hover'); })
						.mousedown(function() { $(this).removeClass('ui-state-active'); })
						.focus(function() { $(this).removeClass('ui-state-focus'); }).end();
				}
		});

		return false;
	}
	function fnModalDialog(title, message, fnCallBack, object1, object2) {
		title = title || '{#Confirm#}';
		$('<div style="text-overflow: clip; overflow: hidden; word-break: break-all; white-space: pre-line;" />')
			.html(message)
			.dialog({
				modal: true,
				resizable: false,
				height: 180,
				closeOnEscape: true,
				title: title,
				buttons: {
					"Yes": {
						"text": "{#btn_Yes#}",
						click: function() {
							$(this).dialog("close");
							if (typeof(fnCallBack) == 'function') fnCallBack(object1, object2);
						},
						"class": 'save_button', 
					},
					"No": {
						"text": "{#btn_No#}",
						click: function() {
							$(this).dialog("close");
						},
						"class": 'cancel_button', 
					},
				},
				close: function(event, ui) {
					$(this).dialog('destroy');
				},
				create: function (event, ui) {
					$(this).closest(".ui-dialog").removeClass('ui-corner-all')
						.find(".ui-corner-all").removeClass('ui-corner-all').end()
						.find(".ui-dialog-buttonpane button").removeClass('ui-button ui-widget ui-state-default ui-state-active ui-state-focus')
						.mouseover(function() { $(this).removeClass('ui-state-hover'); })
						.mousedown(function() { $(this).removeClass('ui-state-active'); })
						.focus(function() { $(this).removeClass('ui-state-focus'); }).end();
				}
		});
		return false;
	}
	function fnShowErrorMessage(title, message, fnCallBack, object) {
		closeWaitingDialog();
		title = title || '{#title_error#}';
		$('<div style="text-overflow: clip; overflow: hidden; {*word-break: break-all;*} white-space: pre-line;" />')
			.html(message)
			.dialog({
				modal: true,
				resizable: false,
				//height: 180,
				width: 600,
				closeOnEscape: true,
				title: title,
				buttons: {
					"close": {
						"text": "{#btn_Close#}",
						click: function() {
							$(this).dialog("close");
						},
						"class": 'save_button', 
					},
				},
				close: function(event, ui) {
					if (typeof(fnCallBack) == 'function') fnCallBack(object);
					$(this).dialog('destroy');
				},
				create: function (event, ui) {
					$(this).closest(".ui-dialog").removeClass('ui-corner-all')
						.find(".ui-corner-all").removeClass('ui-corner-all').end()
						.find(".ui-dialog-buttonpane button").removeClass('ui-button ui-widget ui-state-default ui-state-active ui-state-focus')
						.mouseover(function() { $(this).removeClass('ui-state-hover'); })
						.mousedown(function() { $(this).removeClass('ui-state-active'); })
						.focus(function() { $(this).removeClass('ui-state-focus'); }).end();
				}
		// Червен фон за titlebar
		}).prev(".ui-dialog-titlebar").css("background","#FF9090");
		return false;
	}
	function fnShowInfoMessage(title, message, fnCallBack, object) {
		closeWaitingDialog();
		title = title || 'Info';
		// За Информативни съобщения
		$('<div style="text-overflow: clip; overflow: hidden; word-break: break-all; white-space: pre-line;" />')
			.html(message)
			.dialog({
				modal: true,
				resizable: false,
				maxHeight: 600,
				width: 600,
				closeOnEscape: true,
				title: title,
				buttons: {
					"close": {
						"text": "{#btn_Close#}",
						click: function() {
							$(this).dialog("close");
						},
						"class": 'save_button', 
					},
				},
				close: function(event, ui) {
					if (typeof(fnCallBack) == 'function') fnCallBack(object);
					$(this).dialog('destroy');
				},
				create: function (event, ui) {
					$(this).closest(".ui-dialog").removeClass('ui-corner-all')
						.find(".ui-corner-all").removeClass('ui-corner-all').end()
						.find(".ui-dialog-buttonpane button").removeClass('ui-button ui-widget ui-state-default ui-state-active ui-state-focus')
						.mouseover(function() { $(this).removeClass('ui-state-hover'); })
						.mousedown(function() { $(this).removeClass('ui-state-active'); })
						.focus(function() { $(this).removeClass('ui-state-focus'); }).end();
				}
		// Някакво зелено фон за titlebar
		}).css("overflow-y","scroll").prev(".ui-dialog-titlebar").css("background","#72FF69");
		return false;
	}


	function displayDIV100(data) {
		//return '<div class="td-href">'+data+'</div>'
		return '<span class="td-href">'+data+'</span>'
	}


	function displayCheckbox ( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display' )
			if ( data === "1" )
				return '<img style="vertical-align: middle;" src="/images/checkbox_yes.png" alt="" border="0"><span class="hidden">'+data+'</span>';
			else
			if ( data === "0" )
				return '<span class="hidden">'+data+'</span>';
			else
				return data;
		else
			return data;
	}
	function displayCheckbox_w_no ( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display' )
			if ( data === "1" )
				return '<img style="vertical-align: middle;" src="/images/checkbox_yes.png" alt="" border="0"><span class="hidden">'+data+'</span>';
			else
			if ( data === "0" )
				//return '';
				//return '<img style="vertical-align: middle;" src="/images/checkbox_no.png" alt="" border="0">';
				return '...<span class="hidden">'+data+'</span>';
			else
				return data;
		else
			return data;
	}

	function displayDocUpload ( data, rel ) {
		if ( data )
			//return '<a rel="' +rel+'/'+data+ '" onclick="clickOpenFile(this.rel)" style="cursor: pointer;" title="' +data+ '">'
			return '<a href="' + rel + '/' + data + '" target="_blank" title="' + data + '">'
							+ displayDIV100('<img style="vertical-align: middle;" src="/images/document-16.png" alt="" border="0">')
						+ '</a>'
		else
			return '';
	}


	function displayEllipses( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if (!data) return '';
		data = escapeHtml(data);
		if (type !== 'display') {
//console.log(type);
			return data;
		}
		return '<span title="'+data+'">' + data + '</span>';
	}




	function aviso_truck_type( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display')
			switch (data) {
				case '0': return '{#aviso_truck_type_0#}';
				case '1': return '{#aviso_truck_type_1#}';
				default: return '';
			}
		else return data;
	}
	function aviso_status( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display')
			switch (data) {
				case '0': return '{#aviso_status_0#}';
				case '3': return '{#aviso_status_3#}';
				case '7': return '{#aviso_status_7#}';
				case '8': return '{#aviso_status_8#}';
				case '9': return '{#aviso_status_9#}';
				default: return '';
			}
		else return data;
	}
	function warehouse_type( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display')
			switch (data) {
				case '1': return '{#warehouse_type_1#}';
				case '2': return '{#warehouse_type_2#}';
				case '3': return '{#warehouse_type_3#}';
				default: return '';
			}
		else return data;
	}

	function calendar_is_working_day( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display')
			switch (data) {
				case '1': return '{#calendar_is_working_day_1#}';
				case '2': return '{#calendar_is_working_day_2#}';
				default: return '';
			}
		else return data;
	}



// Renders за datatable, които са общи за всички таблици
	function display_aviso_edit( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display' ) {
			if (!data) data = '...';
			/*{if $smarty.session.userdata.grants.aviso_edit == '1' || $smarty.session.userdata.grants.aviso_view == '1'}*/
			var $edit_delete = '';
			if ('{$smarty.session.table_edit}' == 'aviso')
				$edit_delete = ' edit_delete="{$smarty.session.table_edit}"';
			data = '<a href="/aviso/aviso_edit/'+row.aviso_id+'" rel="edit_'+row.aviso_id+'"'+$edit_delete+' title="{#Edit#} {#table_aviso#}">'+displayDIV100(data)+'</a>';
			/*{else}*/
			data = displayDIV100(data);
			/*{/if}*/
			return data;
		}
		else
			return data;
	}

	function display_pltorg_edit( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display' ) {
			if (!data) data = '...';
			/*{if $smarty.session.userdata.grants.pltorg_edit == '1' || $smarty.session.userdata.grants.pltorg_view == '1'}*/
			var $edit_delete = '';
			if ('{$smarty.session.table_edit}' == 'pltorg')
				$edit_delete = ' edit_delete="{$smarty.session.table_edit}"';
			data = '<a href="/plt/pltorg_edit/'+row.pltorg_id+'" rel="edit_'+row.pltorg_id+'"'+$edit_delete+' title="{#Edit#} {#table_pltorg#}">'+displayDIV100(data)+'</a>';
			/*{else}*/
			data = displayDIV100(data);
			/*{/if}*/
			return data;
		}
		else
			return data;
	}

	function display_pltshop_edit( data, type, row, meta ) {
		if (typeof(type)==='undefined') type = 'display';
		if ( type ==='display' ) {
			if (!data) data = '...';
			/*{if $smarty.session.userdata.grants.pltshop_edit == '1' || $smarty.session.userdata.grants.pltshop_view == '1'}*/
			var $edit_delete = '';
			if ('{$smarty.session.table_edit}' == 'pltshop')
				$edit_delete = ' edit_delete="{$smarty.session.table_edit}"';
			data = '<a href="/plt/pltshop_edit/'+row.pltshop_id+'" rel="edit_'+row.pltshop_id+'"'+$edit_delete+' title="{#Edit#} {#table_pltshop#}">'+displayDIV100(data)+'</a>';
			/*{else}*/
			data = displayDIV100(data);
			/*{/if}*/
			return data;
		}
		else
			return data;
	}


	var footer_row = {};
	var current_menu_text = '';
	function datatable_set_footer (col, render) {
		function sum_footer ( a, b ) { return (a + + (b ? b:0)); }
		if (typeof(render)==='undefined') render = EsCon.formatCurrency;
		var $footer = $(col.footer());
		var td_index = $footer.index();
		var sum = col.data().reduce(sum_footer, 0);
		footer_row[col.index()] = sum;
		var hidden = '';
		if (render) {
			$footer.html( render( sum, 'display', 0, null, true )+hidden);
		} else {
			$footer.html( EsCon.format2(sum) + hidden);
		}
	}
	function datatable_set_cnt_footer (col) {
		function cnt_footer ( a, b ) { return (a + + 1); }
		var $footer = $(col.footer());
		var sum = col.data().reduce(cnt_footer, 0);
		footer_row[col.index()] = sum;
		var hidden = '';
		$footer.html( EsCon.format0(sum)+hidden);
	}
	function datatable_set_rate_footer (col) {
		// Среден Rating. Не се включват rate == 0
		var cnt = 0;
		function sum_footer ( a, b ) {
			if (b != 0) cnt++;
			return (a + + (b ? b:0));
		}
		var $footer = $(col.footer());
		// col.data() е Object { index: "value" }
		var sum = col.data().reduce(sum_footer, 0);
		footer_row[col.index()] = sum;
		var hidden = '';
		$footer.html( (sum/cnt).toFixed(0)+hidden);
	}
	function datatable_get_footer_value (api, col_name) {
		var col = api.column( col_name+':name' );
		return footer_row[col.index()];
	}

	function datatable_add_btn_excel ($appendTo) {
		var frmtHeader = function(data, col, node) {
			// Ако има auto filter - <select ... </select>
			var n = data.indexOf("<select");
			if (n >= 0)
				return data.substr(0, n);
			else
				return data;
		}
		if (oTable.table().footer())
			new $.fn.dataTable.Buttons( oTable, {
				buttons: [ { extend: 'excel', footer: true, filename: current_menu_text,  exportOptions: { format: { header: frmtHeader } } } ],
			});
		else
			new $.fn.dataTable.Buttons( oTable, {
				buttons: [ { extend: 'excel', footer: false, filename: current_menu_text,  exportOptions: { format: { header: frmtHeader } } } ],
			});
		if (typeof($appendTo)==='undefined') $appendTo = $('#headerrow');
		oTable.buttons().container().appendTo($appendTo);
	}

	function datatable_auto_filter (api, in_header) {
		if (typeof(in_header)==='undefined') in_header = true;
		api.columns().every( function () {
			var col = this;
			if (in_header)
				$in_element = $(col.header());
			else
				$in_element = $(col.footer());
			// Ако вече има select, да го изтрием
			$('select', $in_element ).remove();
			var html = '';
			col.data().unique().sort().each( function ( d, j ) {
				if (!d) {
					d = "(empty)";
					html = '<option value="'+d+'">'+d+'</option>' + html;
				} else
					html += '<option value="'+escapeHtml(d)+'">'+escapeHtml(d)+'</option>';
			});
			html = '<option value="(not empty)">(not empty)</option>' + html;
			html = '<option value="">&nbsp;</option>' + html;
			html = '<select style="margin-top: 5px;">' + html + '</select>';
			$(html).appendTo( $in_element )
				.on( 'click', function (event) {
					event.preventDefault();
					event.stopImmediatePropagation();
				})
				.on('mousedown', function (event) {
					event.stopImmediatePropagation();
				})
				.on( 'change', function () {
					var val = $(this).val();
					if (val == '(empty)') val = '^$';
					if (val == '(not empty)') val = '^.+$';
					col.search( val, true, false ).draw();
				});
		});
	}
	function datatable_auto_filter_column (api, col_name, render, add_not_empty) {
		var col = api.column( col_name+':name' );
		if (col.length == 1)
			datatable_set_auto_filter_column (col, render, add_not_empty);
	}
	function datatable_set_auto_filter_column (col, render, add_not_empty) {
		// Ако вече има select, да го изтрием
		$('select', $(col.header()) ).remove();
		var html = '';
		if (typeof(add_not_empty)==='undefined') add_not_empty = true;
		col.data().unique().sort().each( function ( d, j ) {
			if (!d) {
				d = "(empty)";
				html = '<option value="'+d+'">'+d+'</option>' + html;
			} else {
				html += '<option value="'+escapeHtml(d)+'">';
				if (typeof(render)=='function')
					html += render(d);
				else
					html += escapeHtml(d);
				html += '</option>';
			}
		});
		if (add_not_empty)
			html = '<option value="(not empty)">(not empty)</option>' + html;
		html = '<option value="">&nbsp;</option>' + html;
		html = '<select style="margin-top: 5px;">' + html + '</select>';

		$(html).appendTo( $(col.header()) )
		.on( 'click', function (event) {
			event.preventDefault();
			event.stopImmediatePropagation();
		})
		.on('mousedown', function (event) {
			event.stopImmediatePropagation();
		})
		.on( 'change', function () {
			var val = $(this).val();
			if (val == '(empty)')
				val = '^$';
			else
			if (val == '(not empty)')
				val = '^.+$';
			else
			if (val)
				val = '^'+$.fn.dataTable.util.escapeRegex(val)+'$';
			col.search( val, true, false ).draw();
		});
	}


	// Създава списъка от <option> за <select> от двумерен JSON { { id: <id>, name: <name> }, ... }
	function generate_select_option_2D (select_list, selected_key, auto_select_alone) {
		// auto_select_alone == true - ако е един елемент в списъка, направо да го избира
		var html = '';
		if (typeof(auto_select_alone)==='undefined') auto_select_alone = false;

		for (var i = 0, len = select_list.length; i < len; i++) {
			html += '<option value="'+select_list[i].id+'" ';
			if ( select_list[i].id == selected_key && (len > 2 || !auto_select_alone || i > 0))
				html += ' selected';
			else
			if (len == 2 && auto_select_alone && i == 1)
				html += ' selected';
			html += '>'+escapeHtml(select_list[i].name)+'</option>';
		}
		return html;
	}

	// Създава списъка от <option> и <optgroup> за <select> от JSON с неопределена вложена структура - например за charge
	function generate_select_optgroup (select_list, selected_key) {
		var html = '';

		function one_select(key, text) {
			// Ако съм го подал като масив от масив
			if ($.isArray(text)) {
				key = text[0];
				text = text[1];
			}
			html += '<option value="'+key+'"';
			if ( key == selected_key )
				html += ' selected';
			html += '>'+escapeHtml(text)+'</option>';
		}

		for (var key in select_list) {
			// Ако е група
			if(typeof select_list[key] == 'object') {
				// Създаваме група
				html += '<optgroup label="'+escapeHtml(key)+'">';
				for (var sub_key in select_list[key])
					one_select(sub_key, select_list[key][sub_key]);
				html += '</optgroup>';
			} else
				one_select(key, select_list[key]);
		}
		return html;
	}


	function linesIsEquals(obj1, obj2) {
		if ( JSON.stringify(obj1) != JSON.stringify(obj2) )
			return false;
		else
			return true;
	}

	// Автоматично разпъване на textarea
	function textarea_auto_height(e, max_height) {
		if (typeof(max_height)==='undefined') max_height = 150;
		//$(e).height(Math.min(e.scrollHeight, max_height));
		/*
		$(e).height('auto');
		window.setTimeout(function () { $(e).height(Math.min(e.scrollHeight, max_height)); }, 0);
		*/
		e.style.height = '46px';
		e.style.height = Math.min(e.scrollHeight+4, max_height) + 'px';
	}

	// href_post('/contact/', { name: 'Johnny Bravo' });
	function href_post(path, params, method, target) {
		method = method || "POST"; // Set method to post by default if not specified.
		target = target || "_self"; // по подразбиране се отваря в същия прозорец

		var form = document.createElement("form");
		form.setAttribute("method", method);
		form.setAttribute("action", path);
		form.setAttribute("target", '_blank');

		if (params)
			for(var key in params) {
				if(params.hasOwnProperty(key)) {
					var hiddenField = document.createElement("input");
					hiddenField.setAttribute("type", "hidden");
					hiddenField.setAttribute("name", key);
					hiddenField.setAttribute("value", params[key]);

					form.appendChild(hiddenField);
				 }
			}

		document.body.appendChild(form);
		form.submit();
	}

	function waitingDialog(message) {
		if (typeof(message)==='undefined') message = '...';
		//$("body > #loadingScreen-overlay").show();
		$("body > #loadingScreen-overlay").css( 'display', 'block');
		$("body > #loadingScreen #message").html(message);
		$("body > #loadingScreen").css( 'display', 'block');
	}
	function closeWaitingDialog() {
		//$("body > #loadingScreen").hide();
		$("body > #loadingScreen").css( 'display', 'none');
		$("body > #loadingScreen-overlay").css( 'display', 'none');
	}

	function sendEmail(data, type, row) {
		if (type == "display") {
			var subject = [row.building_name, row.space_name, row.space_entrance].join(" / ");
			//var href = encodeURI('mailto:' + (row.object_manager_email || "") + '?subject=' + subject);
			var href = encodeURI('mailto:?subject=' + subject);
			return '<a title="{#email#}" href="' + href + '">' + data + '</a>';
		}
		return data;
	}


	function clickOpenFile(url_display) {
		/*
		// Така се отваря направо в същия прозорец
		var form = document.createElement("form");
		form.setAttribute("method", "POST");
		form.setAttribute("action", url_display);
		document.body.appendChild(form);
		form.submit();
		*/
		
		// Така се отваря в нов прозорец
		window.open(url_display);
	}

	function changeLang(new_lang) {
		jQuery.post('/main_menu/selectlanguage/'+new_lang, { }, function(result) {
			location.reload();
		});
	}


	function select2chosen(el) {
		var opt = $.extend({
			width: "15rem",
			no_results_text: " ",
			placeholder_text_single: " ",
			placeholder_text_multiple: " ",
			//allow_single_deselect: true,
		}, $(el).data());
		$(el).chosen(opt).addClass("hasChosen");
	}

	function datatables_ajax(params) {
		// params = { data: params.url,, callback, settings, url }
		waitingDialog();
		var api = new $.fn.dataTable.Api( params.settings );
		api.clear().columns().search('');
		$.ajax({
			url: params.url,
			method: "POST",
			data: params.data,
			"dataType": "json",
			"cache": false,
			success: function (result) {
//console.log('result.execution_time ' + result.execution_time);
				if (result.hasOwnProperty('fields')) {
//var local_start = Date.now();
					// result.data е масива с данни result.fields е масива с имената на полетата
					var row = {};
					for ( var i=0, len=result.data.length; i<len; i++ ) {
						// За всеки ред се създава Object Json и с него се заменя стария ред
						row = {};
						for (j = 0, j_len = result.data[i].length; j < j_len; j++) {
							row[result.fields[j]] = result.data[i][j];
						}
						result.data[i] = row;
					}
//console.log('JSON parse '+(Date.now() - local_start));
				}
				params.callback( result );
			},
			"error": function (xhr, error, thrown) {
				api.clear().columns().search('').draw();
				closeWaitingDialog();
				if ( error == "parsererror" ) {
					//fnShowErrorMessage('', 'Invalid JSON response');
					fnShowErrorMessage('', xhr.responseText);
					console.log('parsererror', xhr.responseText);
				}
				else if ( xhr.readyState === 4 ) {
					fnShowErrorMessage('', 'Ajax error');
					console.log('Ajax error', xhr.responseText);
				}
				else {
					fnShowErrorMessage('', xhr.responseText);
					console.log('error', thrown, xhr);
				}
			}
		});
	} // datatables_ajax

	$.ajaxSetup({
		method: 'POST',
		//beforeSend: function () { waitingDialog({ }) },
		//complete: function () { closeWaitingDialog() },
	});

	//$(window).unload(function(){});
	
(function($) {
  $.dragScroll = function(options) {
    var settings = $.extend({
      scrollVertical: true,
      scrollHorizontal: true,
      cursor: null
    }, options);

    var clicked = false, draged = false,
      clickY, clickX;

    var getCursor = function() {
      if (settings.cursor) return settings.cursor;
      if (settings.scrollVertical && settings.scrollHorizontal) return 'move';
      if (settings.scrollVertical) return 'row-resize';
      if (settings.scrollHorizontal) return 'col-resize';
    }

    var updateScrollPos = function(e, el) {
      $('html').css('cursor', getCursor());
      var $el = $(el);
      settings.scrollVertical && $el.scrollTop($el.scrollTop() + (clickY - e.pageY));
      settings.scrollHorizontal && $el.scrollLeft($el.scrollLeft() + (clickX - e.pageX));
    }

    $(document).on({
      'mousemove': function(e) {
        if (clicked) {
					updateScrollPos(e, this);
					draged = true;
				}
      },
      'mousedown': function(e) {
				// Right Mouse
				if (e.which === 3) {
					//e.preventDefault();
					clicked = true;
					clickY = e.pageY;
					clickX = e.pageX;
					//return false;
				}
      },
      'mouseup': function() {
        clicked = false;
        $('html').css('cursor', 'auto');
      },
      'contextmenu': function(e) {
				if (draged) {
					clicked = false;
					draged = false;
					//e.preventDefault();
					return false;
				}
      },
    });
  }
}(jQuery))

$.dragScroll();