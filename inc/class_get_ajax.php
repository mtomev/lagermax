<?php
class get_ajax {
		
	function __construct ($smarty) {
		$this->smarty = $smarty;
	}
	
	function __destruct () {}

// _base::get_select_list_ajax($table, $order_by = null, $where = null, $field_name = null, $field_id = null, $add_select = null)

	// връща списъка от building за формиране на <select>
	function get_building_list () {
		// връща списък за select_building
		// <field_id>=<id>
		_base::parseREQUEST_p('p1', $field_id, $id);
		if ($id)
			$data = _base::get_select_list_ajax('building', 'building_id', "where $field_id = $id");
		else
			$data = _base::get_select_list_ajax('building', 'building_id', '');
		echo json_encode($data);
	}

	// връща списъка от space за формиране на <select>
	function get_space_list () {
		// връща списък за select_space
		// <field_id>=<id>
		_base::parseREQUEST_p('p1', $field_id, $id);
		if (!DB_FIREBIRD)
			$data = _base::get_select_list_ajax('space', 'space_id', "where $field_id = $id", "concat(space_name,' / ',space_entrance)");
		else
			//$data = _base::get_select_list_ajax('space', 'space_id', "where $field_id = $id", "space_name||' / '||space_entrance");
			$data = _base::get_select_list_ajax('space', 'space_id', "where $field_id = $id", "space_name");
		echo json_encode($data);
	}


}
?>
