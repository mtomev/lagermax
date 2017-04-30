<?php
	require_once(COMPS_DIR.'/fpdf181/code128.php');
	class plt_PDF extends PDF_Code128 {
		public $footers = array();
		public $header_text = false;
		public $page_shift = 0;
		// Page header
		function Header() {
			$page = $this->PageNo() - $this->page_shift;
			if ($this->header_text and $page > 1) {
				$this->SetFont($this->FontFamily,'',11);
				$this->Cell($this->GetPageWidth()-$this->lMargin-$this->rMargin,5, iconv('UTF-8', 'windows-1251', $this->header_text.' / стр.'.$page), 0, 1, 'R');
			}
		}

		// Page footer
		function Footer() {
			/*
			$this->SetY(-20);
			$this->SetFont('Arial','',8);
			//$this->Cell(0,10,'Page '.$this->PageNo().'/{nb}',0,0,'C');
			foreach($this->footers as $footer)
				$this->Cell(0,3, iconv('UTF-8', 'windows-1252', $footer), 0, 1, 'C');
			*/
		}

		//Computes the number of lines a MultiCell of width w will take
		function NbLines($w,$txt) {
			$cw=&$this->CurrentFont['cw'];
			if($w==0)
				$w=$this->w-$this->rMargin-$this->x;
			$wmax=($w-2*$this->cMargin)*1000/$this->FontSize;
			$s=str_replace("\r",'',$txt);
			$nb=strlen($s);
			if($nb>0 and $s[$nb-1]=="\n")
				$nb--;
			$sep=-1;
			$i=0;
			$j=0;
			$l=0;
			$nl=1;
			while($i<$nb) {
				$c=$s[$i];
				if($c=="\n")
				{
					$i++;
					$sep=-1;
					$j=$i;
					$l=0;
					$nl++;
					continue;
				}
				if($c==' ')
					$sep=$i;
				$l+=$cw[$c];
				if($l>$wmax) {
					if($sep==-1) {
						if($i==$j)
							$i++;
					}
					else
						$i=$sep+1;
					$sep=-1;
					$j=$i;
					$l=0;
					$nl++;
				}
				else
					$i++;
			}
			return $nl;
		}
	}

	class plt {
		function __construct ($smarty) {
			$this->smarty = $smarty;
		}

		function __destruct () {}

		function deflt () {
			$this->pltorg();
		}


		function pltorg () {
		 	if (!_base::CheckAccess('pltorg')) return;

			$_SESSION['main_menu'] = 'plt';
			$_SESSION['sub_menu'] = 'pltorg';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/plt/pltorg');

			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];

			if (!isset($_SESSION[$sub_menu]['from_date']))
				// Днешна дата - 7 дни
				//$_SESSION[$sub_menu]['from_date'] = date('Y-m-d', strtotime(date("Y-m-d"). ' - 7 days'));
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			_base::get_select_list('org', null, 'org_name');

			_base::set_table_edit_AccessRights('pltorg');
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		// Тази функция се вика само като ajax
		function get_list_pltorg () {
		 	if (!_base::CheckAccess('pltorg')) return;

			$sub_menu = 'pltorg';
			_base::readFilterToSESSION_new($sub_menu);
			$where = "WHERE (1=1)";

			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			
			if ($_SESSION[$sub_menu]['org_id'])
				$where .= " and (org_id = {$_SESSION[$sub_menu]['org_id']})";

			$from_date = $_SESSION[$sub_menu]['from_date'];
			$to_date = $_SESSION[$sub_menu]['to_date'];
			if ($from_date)
				$where .= " and pltorg_date >= '$from_date'";
			if ($to_date)
				$where .= " and pltorg_date <= '$to_date'";

			$data = _base::nomen_list('pltorg', true, 'pltorg_id', $where);

			echo json_encode(array('data' => $data));
		}

		function pltorg_edit () {
			if (!_base::CheckGrant('pltorg_view'))
				if (!_base::CheckAccess('pltorg_edit')) return;

			// pltorg_id
			$id = intVal($_REQUEST['p1']);

			$data = _base::nomen_list_edit('pltorg', $id, true, null, $add_select);
			
			if (!$id) {
				// Ако е нов
				if (intVal($_SESSION['userdata']['org_id']))
					$data['org_id'] = $_SESSION['userdata']['org_id'];
				else
					// Ако потребителя не е към някой Доставчик, то да вземем Доставчика от параметъра за справката
					$data['org_id'] = $_SESSION['pltorg']['org_id'];
			}
			else {
				// Ако е корекция на стар

				// Ако потребител към някой доставчик, без право да вижда всички доставчици, се опитва да отвори неправомерно друго Авизо
				if (intVal($_SESSION['userdata']['org_id']) and $data['org_id'] != $_SESSION['userdata']['org_id'] and !$_SESSION['userdata']['grants']['view_all_suppliers']) {
					$_SESSION['display_path'] = 'main_menu/deflt.tpl';
					$_SESSION['display_text'] = $this->smarty->getConfigVars('access_denied');
					return;
				}
			}
			$this->smarty->assign('data', $data);

			_base::get_select_list('org', null, 'org_name');

			$this->smarty->assign ('callback_url', "$_SERVER[HTTP_REFERER]");
			

			$_SESSION['pltorg_id'] = $id;
			$_SESSION['table_edit'] = 'pltorg';
			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function pltorg_save () {
			if (!_base::CheckAccess('pltorg_edit', false)) return;

			// pltorg_id
			$id = intVal($_REQUEST['p1']);

			$aviso_id = $_POST['aviso_id'];

			// Проверки за неправомерност
			// Ако потребителя е с фиксиран org_id, проверка дали това Авизо е на същия org_id
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'] and $_SESSION['userdata']['org_id']) {
				if ($id)
					$temp = _base::select_sql("select org_id from pltorg WHERE pltorg_id = $id");
				else
					$temp['org_id'] = $_POST['org_id'];
				if ($temp['org_id'] != $_SESSION['userdata']['org_id'])
					_base::show_error($this->smarty->getConfigVars('access_denied'));
			}


			_base::start_transaction();

			$query = new ExecQuery('pltorg');

			// Ако не е по Авизо
			if (!$aviso_id) {
				$query->AddParam('org_id', 'n', 0);
				$query->AddParam('pltorg_date', 'd');
			}

			$query->AddParam('pltorg_refnumb');
			$query->AddParam('pltorg_driver');
			$query->AddParam('pltorg_note');

			$query->AddParam('qty_plt_eur', 'n', 0);
			$query->AddParam('qty_plt_chep', 'n', 0);
			$query->AddParam('qty_plt_other', 'n', 0);
			$query->AddParam('qty_ret_plt_eur', 'n', 0);
			$query->AddParam('qty_ret_plt_chep', 'n', 0);
			$query->AddParam('qty_ret_plt_other', 'n', 0);
			$query->AddParam('qty_claim_plt_eur', 'n', 0);
			$query->AddParam('qty_claim_plt_chep', 'n', 0);
			$query->AddParam('qty_claim_plt_other', 'n', 0);

			if ($id != 0) {
				$query->update(["pltorg_id" => $id]);
			}
			else {
				$id = $query->insert();
			}
			$_SESSION['pltorg_id'] = $id;

			// Ако е по Авизо, да обновим количествата в Авизото
			if ($aviso_id) {
				unset($query);
				$query = new ExecQuery('aviso', false);
				$query->add_cr_mo = false;
				
				$query->AddParamExt('aviso_plt_eur', $_POST['qty_plt_eur'], 'n', 0);
				$query->AddParamExt('aviso_plt_chep', $_POST['qty_plt_chep'], 'n', 0);
				$query->AddParamExt('aviso_plt_other', $_POST['qty_plt_other'], 'n', 0);
				$query->AddParamExt('aviso_ret_plt_eur', $_POST['qty_ret_plt_eur'], 'n', 0);
				$query->AddParamExt('aviso_ret_plt_chep', $_POST['qty_ret_plt_chep'], 'n', 0);
				$query->AddParamExt('aviso_ret_plt_other', $_POST['qty_ret_plt_other'], 'n', 0);
				$query->AddParamExt('aviso_claim_plt_eur', $_POST['qty_claim_plt_eur'], 'n', 0);
				$query->AddParamExt('aviso_claim_plt_chep', $_POST['qty_claim_plt_chep'], 'n', 0);
				$query->AddParamExt('aviso_claim_plt_other', $_POST['qty_claim_plt_other'], 'n', 0);

				$query->update(["aviso_id" => $aviso_id]);
			}

			_base::commit_transaction();
			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $id);
			echo $id;
		}

		function pltorg_delete () {
		 	if (!_base::CheckAccess('pltorg_delete')) return;

			// pltorg_id
			$id = intval($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				$temp = _base::select_sql("select aviso_id, org_id from pltorg WHERE pltorg_id = $id");

				// Ако потребителя е с фиксиран org_id, проверка дали това Авизо е на същия org_id
				if (!$_SESSION['userdata']['grants']['view_all_suppliers'] and $_SESSION['userdata']['org_id']) {
					if ($temp['org_id'] != $_SESSION['userdata']['org_id'])
						_base::show_error($this->smarty->getConfigVars('access_denied'));
				}

				_base::start_transaction();

				$sql_query = "DELETE FROM pltorg WHERE pltorg_id = $id";
				_base::execute_sql($sql_query);

				// Ако е по Авизо, да нулираме количествата в Авизото
				if ($temp['aviso_id']) {
					unset($query);
					$query = new ExecQuery('aviso', false);
					$query->add_cr_mo = false;
					
					$query->AddParamExt('aviso_plt_eur', 0, 'n', 0);
					$query->AddParamExt('aviso_plt_chep', 0, 'n', 0);
					$query->AddParamExt('aviso_plt_other', 0, 'n', 0);
					$query->AddParamExt('aviso_ret_plt_eur', 0, 'n', 0);
					$query->AddParamExt('aviso_ret_plt_chep', 0, 'n', 0);
					$query->AddParamExt('aviso_ret_plt_other', 0, 'n', 0);
					$query->AddParamExt('aviso_claim_plt_eur', 0, 'n', 0);
					$query->AddParamExt('aviso_claim_plt_chep', 0, 'n', 0);
					$query->AddParamExt('aviso_claim_plt_other', 0, 'n', 0);

					$query->update(["aviso_id" => $temp['aviso_id']]);
				}

				_base::commit_transaction();

				unset($_SESSION['pltorg_id']);
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}


		function pltshop () {
		 	if (!_base::CheckAccess('pltshop')) return;

			$_SESSION['main_menu'] = 'plt';
			$_SESSION['sub_menu'] = 'pltshop';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/plt/pltshop');

			if (!isset($_SESSION[$sub_menu]['from_date']))
				// Днешна дата - 7 дни
				//$_SESSION[$sub_menu]['from_date'] = date('Y-m-d', strtotime(date("Y-m-d"). ' - 7 days'));
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			_base::get_select_list('shop', null, 'shop_name');

			_base::set_table_edit_AccessRights('pltshop');
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		// Тази функция се вика само като ajax
		function get_list_pltshop () {
		 	if (!_base::CheckAccess('pltshop')) return;

			$sub_menu = 'pltshop';
			_base::readFilterToSESSION_new($sub_menu);
			$where = "WHERE (1=1)";

			if ($_SESSION[$sub_menu]['shop_id'])
				$where .= " and (shop_id = {$_SESSION[$sub_menu]['shop_id']})";

			$from_date = $_SESSION[$sub_menu]['from_date'];
			$to_date = $_SESSION[$sub_menu]['to_date'];
			if ($from_date)
				$where .= " and pltshop_date >= '$from_date'";
			if ($to_date)
				$where .= " and pltshop_date <= '$to_date'";

			$data = _base::nomen_list('pltshop', true, 'pltshop_id', $where);

			echo json_encode(array('data' => $data));
		}

		function pltshop_edit () {
			if (!_base::CheckGrant('pltshop_view'))
				if (!_base::CheckAccess('pltshop_edit')) return;

			// pltshop_id
			$id = intVal($_REQUEST['p1']);

			$data = _base::nomen_list_edit('pltshop', $id, true, null, $add_select);
			
			if (!$id) {
				// Ако е нов
				$data['shop_id'] = $_SESSION['pltshop']['shop_id'];
			}
			else {
				// Ако е корекция на стар

			}
			$this->smarty->assign('data', $data);

			_base::get_select_list('shop', null, 'shop_name');

			$this->smarty->assign ('callback_url', "$_SERVER[HTTP_REFERER]");
			

			$_SESSION['pltshop_id'] = $id;
			$_SESSION['table_edit'] = 'pltshop';
			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function pltshop_save () {
			if (!_base::CheckAccess('pltshop_edit', false)) return;

			// pltshop_id
			$id = intVal($_REQUEST['p1']);

			_base::start_transaction();

			$query = new ExecQuery('pltshop');

			$query->AddParam('shop_id', 'n', 0);
			$query->AddParam('pltshop_date', 'd');

			$query->AddParam('pltshop_refnumb');
			$query->AddParam('pltshop_driver');
			$query->AddParam('pltshop_note');

			$query->AddParam('qty_plt_eur', 'n', 0);
			$query->AddParam('qty_plt_chep', 'n', 0);
			$query->AddParam('qty_plt_other', 'n', 0);
			$query->AddParam('qty_ret_plt_eur', 'n', 0);
			$query->AddParam('qty_ret_plt_chep', 'n', 0);
			$query->AddParam('qty_ret_plt_other', 'n', 0);
			$query->AddParam('qty_claim_plt_eur', 'n', 0);
			$query->AddParam('qty_claim_plt_chep', 'n', 0);
			$query->AddParam('qty_claim_plt_other', 'n', 0);

			if ($id != 0) {
				$query->update(["pltshop_id" => $id]);
			}
			else {
				$id = $query->insert();
			}
			$_SESSION['pltshop_id'] = $id;

			_base::commit_transaction();
			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $id);
			echo $id;
		}

		function pltshop_delete () {
		 	if (!_base::CheckAccess('pltshop_delete')) return;

			// pltshop_id
			$id = intval($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				_base::start_transaction();

				$sql_query = "DELETE FROM pltshop WHERE pltshop_id = $id";
				_base::execute_sql($sql_query);

				_base::commit_transaction();

				unset($_SESSION['pltshop_id']);
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}


		// Генериране на ПРИЕМНО - ПРЕДАВАТЕЛЕН ПРОТОКОЛ
		function pltorg_display () {
			if (!_base::CheckGrant('pltorg_view'))
				if (!_base::CheckAccess('pltorg_edit')) return;
			// pltorg_id
			$pltorg_id = intVal($_REQUEST['p1']);
			// $_REQUEST['p2'] = thumb
			$thumb = ($_REQUEST['p2'] == 'thumb');
			$small_thumb = ($_REQUEST['p2'] == 'small_thumb');

			// Ако се иска thumb
			if ($thumb || $small_thumb) {
				_base::display_file('0.pdf', $thumb, $small_thumb);
				return ;
			}
echo '';
return ;
			// Данните от заглавния ред
			$query_result = _base::get_query_result("SELECT * FROM view_pltorg WHERE pltorg_id = $pltorg_id");
			$pltorg = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);

			// Ако потребител към някой доставчик, без право да вижда всички доставчици, се опитва да отвори неправомерно друго Авизо
			if (intVal($_SESSION['userdata']['org_id']) and $pltorg['org_id'] != $_SESSION['userdata']['org_id'] and !$_SESSION['userdata']['grants']['view_all_suppliers']) {
				$_SESSION['display_path'] = 'main_menu/deflt.tpl';
				$_SESSION['display_text'] = $this->smarty->getConfigVars('access_denied');
				return;
			}

			// Данните за Доставчика
			$query_result = _base::get_query_result("SELECT * FROM view_org WHERE org_id = {$pltorg['org_id']}");
			$org = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);

			// Същинско генериране на файла
			$pdf = new plt_PDF();
			$pdf->AddFont('Calibri','','calibri.php');
			$pdf->AddFont('Calibri','B','calibrib.php');
			$pdf->AddFont('Calibri','BI','calibribi.php');
			$pdf->AddFont('Calibri','I','calibrii.php');

			// 210 - 10 - 10 = 190
			$pdf->SetLeftMargin(10);
			$pdf->SetRightMargin(10);
			
			$pdf->header_text = 'Приемно-предавателен протокол '.$pltorg['pltorg_id'];

		for($orig_copy = 1; $orig_copy <= 2; $orig_copy++) {
			$pdf->AddPage();
			$pdf->Image(INC_DIR.'/lagermax_logo.png',10,10,45);

			// 190-45 = 145
			$pdf->SetX(55);
			$pdf->SetFont('Calibri','BI',16);
			$pdf->Cell(145, 8, iconv('UTF-8', 'windows-1251', '„Лагермакс Спедицио България“ ЕООД'), 0, 1, 'R');

			//$pdf->SetXY(55, 18);
			$pdf->SetFont('Calibri','',10);
			$pdf->SetX(55);
			$pdf->Cell(145, 4, iconv('UTF-8', 'windows-1251', $warehouse['w_group_address']), 0, 1, 'R');
			$pdf->SetX(55);
			$pdf->Cell(145, 4, iconv('UTF-8', 'windows-1251', 'тел.: (+359) 2/996 22 13, ЕИК 131526370'), 0, 1, 'R');
			
			$pdf->SetFont('Calibri','B',16);
			$pdf->SetX(10);
			$pdf->Cell(150, 10, iconv('UTF-8', 'windows-1251', 'ПРИЕМНО - ПРЕДАВАТЕЛЕН ПРОТОКОЛ'), 'LTB', 0, 'C');

			// ОРИГИНАЛ / КОПИЕ
			if ($orig_copy == 1)
				$pdf->Cell(40,10, iconv('UTF-8', 'windows-1251', 'ОРИГИНАЛ'), 'TRB', 1, 'C');
			else {
				$pdf->SetTextColor(192);
				$pdf->Cell(40,10, iconv('UTF-8', 'windows-1251', 'КОПИЕ'), 'TRB', 1, 'C');
				$pdf->SetTextColor(0);
			}


			// Barcode 70, Дата 60, Час 60
			$pdf->SetFont('Calibri','',12);
			$pdf->SetX(10);
			$y = $pdf->GetY();
			$barcode_width = 80;
			$pdf->Cell($barcode_width, 20, '', 1, 0, 'L');

			$pdf->SetFont('Calibri','B',16);
			$pdf->Cell(35, 8, iconv('UTF-8', 'windows-1251', _base::MySqlDate2Str($aviso['aviso_date'])), 1, 0, 'C');
			$pdf->Cell(25, 8, iconv('UTF-8', 'windows-1251', substr($aviso['aviso_time'],0,5)), 1, 0, 'C');
			$pdf->Cell(190-60-$barcode_width, 8, iconv('UTF-8', 'windows-1251', $aviso['warehouse_code']), 1, 1, 'C');

			// Доставчик:, платформа: warehouse_code
			$y1 = $pdf->GetY();
			$pdf->SetX(10+$barcode_width);
			$pdf->SetFont('Calibri','B',11);
			$pdf->Cell(190-$barcode_width, 6, iconv('UTF-8', 'windows-1251', $aviso['org_name']), 0, 0, 'L');
			$pdf->SetXY(10+$barcode_width, $y1+5);
			$pdf->SetFont('Calibri','',10);
			$pdf->Cell(190-$barcode_width, 7, iconv('UTF-8', 'windows-1251', $aviso['aviso_truck_no']), 0, 0, 'L');
			$pdf->SetXY(10+$barcode_width, $y1+5);
			$pdf->Cell(190-$barcode_width, 3, iconv('UTF-8', 'windows-1251', $aviso['aviso_driver_name']), 0, 0, 'R');
			$pdf->SetXY(10+$barcode_width, $y1+8);
			$pdf->Cell(190-$barcode_width, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_driver_phone']), 0, 0, 'R');
			//$pdf->MultiCell(190-$barcode_width, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_driver_name'] . "\n" . $aviso['aviso_driver_phone']), 0, 'R');
			$pdf->SetXY(10+$barcode_width, $y1);
			$pdf->Cell(190-$barcode_width, 12, '', 1, 0, 'L');


			// Сега се събират до 13 цифри при 0.5 мащабиране
			$pdf->SetFont('Calibri','B',14);
			$pdf->Code128(20,$y+2,$aviso['aviso_id'],$barcode_width-10, 12);
			$pdf->SetXY(20,$y+15);
			$pdf->Write(5, $aviso['aviso_id']);



			// Общи приказки
			$pdf->Ln(10);
			$pdf->SetFont('Calibri','I',11);
			$s = '* Фирма Лагермакс Спедицио България ЕООД не носи отговорност за съдържанието на оригинално запечатани палети и колети.';
			$pdf->MultiCell(190,4, iconv('UTF-8', 'windows-1251', $s), 0, 'L');

			// Ако има Забележка
			$s = $aviso['aviso_reject_reason'];
			if ($s) {
				$pdf->Ln(1);
				$pdf->SetFont('Calibri','B',10);
				$pdf->MultiCell(190,4, iconv('UTF-8', 'windows-1251', 'Забележка:'), 0, 'L');
				$pdf->SetFont('Calibri','',10);
				$pdf->MultiCell(190,4, iconv('UTF-8', 'windows-1251', $s), 0, 'L');
			}
			
			// Амбалаж
			$pdf->Ln(5);
			$pdf->SetFont('Calibri','B',11);
			$pdf->MultiCell(190,4, iconv('UTF-8', 'windows-1251', 'Амбалаж:'), 0, 'L');
			$pdf->SetFont('Calibri','',11);
			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Доставени EUR:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_plt_eur']), 0, 0, 'R');
			$pdf->Cell(20, 4, '', 0, 0, '');
			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Върнати EUR:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_ret_plt_eur']), 0, 0, 'R');
			$pdf->Cell(20, 4, '', 0, 0, '');
			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Рекламация EUR:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_claim_plt_eur']), 0, 1, 'R');

			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Доставени CHEP:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_plt_chep']), 0, 0, 'R');
			$pdf->Cell(20, 4, '', 0, 0, '');
			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Върнати CHEP:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_ret_plt_chep']), 0, 0, 'R');
			$pdf->Cell(20, 4, '', 0, 0, '');
			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Рекламация CHEP:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_claim_plt_chep']), 0, 1, 'R');

			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Доставени скари:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_plt_other']), 0, 0, 'R');
			$pdf->Cell(20, 4, '', 0, 0, '');
			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Върнати скари:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_ret_plt_other']), 0, 0, 'R');
			$pdf->Cell(20, 4, '', 0, 0, '');
			$pdf->Cell(30, 4, iconv('UTF-8', 'windows-1251', 'Рекламация скари:'), 0, 0, 'R');
			$pdf->Cell(10, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_claim_plt_other']), 0, 1, 'R');

			
			// Предал / Приел
			$pdf->Ln(10);
			$pdf->SetFont('Calibri','',11);
			$pdf->Cell(95, 5, iconv('UTF-8', 'windows-1251', 'Предал:...................................................................'), 0, 0, 'C');
			$pdf->Cell(95, 5, iconv('UTF-8', 'windows-1251', 'Приел:...................................................................'), 0, 1, 'C');

			$pdf->SetFont('Calibri','I',10);
			$pdf->Cell(95, 4, iconv('UTF-8', 'windows-1251', '/Име и подпис/'), 0, 0, 'C');
			$pdf->Cell(95, 4, iconv('UTF-8', 'windows-1251', '/Име, подпис и печат/'), 0, 1, 'C');

			$pdf->Cell(95, 4, iconv('UTF-8', 'windows-1251', $aviso['org_name']), 0, 0, 'C');
			$pdf->Cell(95, 4, iconv('UTF-8', 'windows-1251', 'Лагермакс Спедицио България ЕООД'), 0, 1, 'C');

			$pdf->page_shift = $pdf->PageNo();
		}


			// I - направо се отваря в прозореца
			// D - download
			$pdf->Output('I', $aviso['ppp_doc']);
			_base::put_sys_oper(__METHOD__, 'pdf', 'aviso', $aviso_id);
		}

	}
?>
