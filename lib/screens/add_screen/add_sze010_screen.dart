import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_aucs/models/sqb010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/screens/commom/error_dialog.dart';
import 'package:projeto_aucs/screens/commom/menu_drawer.dart';
import 'package:projeto_aucs/screens/commom/success_dialog.dart';
import 'package:projeto_aucs/screens/sze010_screen/sze010_screen.dart';
import 'package:projeto_aucs/services/sqb010_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:projeto_aucs/validations/colaboradorValidation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

const List<String> active = <String>['Sim', 'Não'];

class AddSze010Screen extends StatefulWidget {
  final Function refreshFunction;
  final Sze010 sze010;
  final bool isEditing;

  const AddSze010Screen({
    Key? key,
    required this.refreshFunction,
    required this.sze010,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<AddSze010Screen> createState() => _AddSze010ScreenState();
}

class _AddSze010ScreenState extends State<AddSze010Screen> {
  String email = 'Seja bem-vindo(a)';
  final Sqb010Service _sqb010service = Sqb010Service();
  Map<String, String> database = {};
  List<String> depto = [];
  bool nameValidation = false;
  colaboradorValidation validation = colaboradorValidation();
  TextEditingController zeNomeController = TextEditingController();
  TextEditingController zeMatController = TextEditingController();
  TextEditingController zeFperaqController = TextEditingController();
  TextEditingController zeAdmissaController = TextEditingController();
  TextEditingController zeFervencController = TextEditingController();
  TextEditingController zeDirferiController = TextEditingController();
  TextEditingController zeFeragenController = TextEditingController();
  TextEditingController zeDiasferController = TextEditingController();
  TextEditingController zeSaldferController = TextEditingController();
  TextEditingController zeAnteferController = TextEditingController();
  TextEditingController zeFerpgController = TextEditingController();
  TextEditingController zeDeptoController = TextEditingController();
  TextEditingController zeNiverController = TextEditingController();
  TextEditingController zeConveniController = TextEditingController();
  TextEditingController activeController = TextEditingController();
  DateTime? pickedDate;
  DateTime? pickedDateNiver;
  DateTime? pickedDateConv;
  DateTime initialDate = DateTime.now();
  String feriasVencidas = active.first;
  String direitoFerias = active.first;
  String feriasAgendadas = active.first;
  String antecipFerias = active.first;
  String feriasPagas = active.first;
  var departamento;
  String userId = '';
  bool isRequestReady = true;

  @override
  void initState() {
    zeNomeController.text = widget.sze010.ze_nome;
    zeMatController.text = widget.sze010.ze_mat;
    zeFervencController.text = widget.sze010.ze_fervenc;
    zeDirferiController.text = widget.sze010.ze_dirferi;
    zeFeragenController.text = widget.sze010.ze_feragen;
    zeDiasferController.text = widget.sze010.ze_diasfer.toString();
    zeSaldferController.text = widget.sze010.ze_saldfer.toString();
    zeAnteferController.text = widget.sze010.ze_antefer;
    zeFerpgController.text = widget.sze010.ze_ferpg;
    zeDeptoController.text = widget.sze010.ze_depto;
    (widget.isEditing)
        ? (widget.sze010.ze_niver.trim().isNotEmpty)
            ? zeNiverController.text = DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(widget.sze010.ze_niver))
            : zeNiverController.text =
                DateFormat('dd/MM/yyyy').format(initialDate)
        : zeNiverController.text = DateFormat('dd/MM/yyyy').format(initialDate);
    (widget.isEditing)
        ? (widget.sze010.ze_conveni.trim().isNotEmpty)
            ? zeConveniController.text = DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(widget.sze010.ze_conveni))
            : zeConveniController.text =
                DateFormat('dd/MM/yyyy').format(initialDate)
        : zeConveniController.text =
            DateFormat('dd/MM/yyyy').format(initialDate);
    (widget.isEditing)
        ? zeAdmissaController.text = DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(widget.sze010.ze_admissa))
        : zeAdmissaController.text =
            DateFormat('dd/MM/yyyy').format(initialDate);
    (widget.isEditing)
        ? zeFperaqController.text = DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(widget.sze010.ze_fperaq))
        : zeFperaqController.text =
            DateFormat('dd/MM/yyyy').format(initialDate);
    getSqb010();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        title: (widget.isEditing)
            ? const Text('Editar Colaborador')
            : const Text('Criar Colaborador'),
        titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            onPressed: () {
              registerCampaing(context);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: (widget.isEditing)
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: zeNomeController,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        labelText: "Nome: ",
                      ),
                    ), // Nome
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                          controller: zeAdmissaController,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: "Data Admissão: ",
                          ),
                          readOnly: true,
                          onTap: () async {
                            pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.parse('1900-01-01'),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                            );

                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(pickedDate!);

                              setState(() {
                                zeAdmissaController.text =
                                    formattedDate; //set foratted date to TextField value.
                              });
                            } else {
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(initialDate);

                              setState(() {
                                zeAdmissaController.text = (widget.isEditing)
                                    ? DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(
                                            widget.sze010.ze_admissa))
                                    : formattedDate; //set foratted date to TextField value.
                              });
                            }
                          }),
                    ), // Admissao
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                          controller: zeFperaqController,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: "Periodo Aquisitivo: ",
                          ),
                          readOnly: true,
                          onTap: () async {
                            pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.parse('1900-01-01'),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                            );

                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(pickedDate!);

                              setState(() {
                                zeFperaqController.text =
                                    formattedDate; //set foratted date to TextField value.
                              });
                            } else {
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(initialDate);

                              setState(() {
                                zeFperaqController.text = (widget.isEditing)
                                    ? DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(
                                            widget.sze010.ze_admissa))
                                    : formattedDate; //set foratted date to TextField value.
                              });
                            }
                          }),
                    ), // Periodo Aquisitivo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                          controller: zeNiverController,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: "Nascimento: ",
                          ),
                          readOnly: true,
                          onTap: () async {
                            pickedDateNiver = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.parse('1900-01-01'),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                            );

                            if (pickedDateNiver != null) {
                              String formattedDate = DateFormat('dd/MM/yyyy')
                                  .format(pickedDateNiver!);

                              setState(() {
                                zeNiverController.text =
                                    formattedDate; //set foratted date to TextField value.
                              });
                            } else {
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(initialDate);

                              setState(() {
                                zeNiverController.text = (widget.isEditing)
                                    ? DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(widget.sze010.ze_niver))
                                    : formattedDate; //set foratted date to TextField value.
                              });
                            }
                          }),
                    ), // Nascimento
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                          controller: zeConveniController,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: "Venc. Convênio: ",
                          ),
                          readOnly: true,
                          onTap: () async {
                            pickedDateConv = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.parse('1900-01-01'),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                            );

                            if (pickedDateConv != null) {
                              String formattedDate = DateFormat('dd/MM/yyyy')
                                  .format(pickedDateConv!);

                              setState(() {
                                zeConveniController.text =
                                    formattedDate; //set foratted date to TextField value.
                              });
                            } else {
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(initialDate);

                              setState(() {
                                zeConveniController.text = (widget.isEditing)
                                    ? DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(
                                            widget.sze010.ze_conveni))
                                    : formattedDate; //set foratted date to TextField value.
                              });
                            }
                          }),
                    ), // Convenio
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              'Férias Vencidas?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton<String>(
                              value: (widget.sze010.ze_fervenc == '2')
                                  ? feriasVencidas = 'Não'
                                  : feriasVencidas,
                              icon: const Icon(Icons.arrow_downward, size: 20,),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              items: active.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  feriasVencidas = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ), // ferias vencidas
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              'Direito Férias?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton<String>(
                              value: (widget.sze010.ze_dirferi == '2')
                                  ? direitoFerias = 'Não'
                                  : direitoFerias,
                              icon: const Icon(Icons.arrow_downward, size: 20),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              items: active.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  direitoFerias = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ), // direito ferias
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              'Férias Agendadas?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton<String>(
                              value: (widget.sze010.ze_feragen == '2')
                                  ? feriasAgendadas = 'Não'
                                  : feriasAgendadas,
                              icon: const Icon(Icons.arrow_downward, size: 20),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              items: active.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  feriasAgendadas = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ), // ferias agendadas
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              'Antecipação Férias?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton<String>(
                              value: (widget.sze010.ze_antefer == '2')
                                  ? antecipFerias = 'Não'
                                  : antecipFerias,
                              icon: const Icon(Icons.arrow_downward, size: 20),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              items: active.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  antecipFerias = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ), // antecipacao ferias
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              'Férias Pagas?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton<String>(
                              value: (widget.sze010.ze_ferpg == '2')
                                  ? feriasPagas = 'Não'
                                  : feriasPagas,
                              icon: const Icon(Icons.arrow_downward, size: 20),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              items: active.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  feriasPagas = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ), // ferias pagas
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              'Departamento?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: DropdownButton<String>(
                              value: departamento,
                              icon: const Icon(Icons.arrow_downward, size: 20),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              items: depto.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  departamento = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ), // departamento
                    (isRequestReady)
                        ? InkWell(
                                onTap: () {
                                    setState(() {
                                      isRequestReady = false;
                                    });
                                    registerCampaing(context);
                                  },
                                  child: Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: BorderRadius.circular(30)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text('Editar',
                                                style: GoogleFonts.actor(
                                                  textStyle: const TextStyle(fontSize: 20),
                                                  color: Colors.black,
                                                ),
                                              )
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              color: Colors.black.withAlpha(50)
                                            ),
                                            child: const Icon(
                                              Icons.chevron_right_rounded, 
                                              size: 30, 
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              )
                        : InkWell(
                            onTap: () {
                                ErrorDialog(
                                    context, "Aguarde o processamento.");
                              },
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Aguarde',
                                          style: GoogleFonts.actor(
                                            textStyle: const TextStyle(fontSize: 20),
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: zeNomeController,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      labelText: "Nome: ",
                    ),
                    onSubmitted: (value) {
                      if (validation.searchUniqueName(zeNomeController.text)) {
                        ErrorDialog(
                            context,
                            'Já existe colaborador cadastrado com esse nome, '
                            'favor verificar!');
                        nameValidation = true;
                        zeNomeController.text = '';
                      } else {
                        nameValidation = false;
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                        controller: zeAdmissaController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: "Data Admissão: ",
                        ),
                        readOnly: true,
                        onTap: () async {
                          pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.parse('1900-01-01'),
                            lastDate:
                                DateTime.now().add(const Duration(days: 90)),
                          );

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(pickedDate!);

                            setState(() {
                              zeAdmissaController.text =
                                  formattedDate; //set foratted date to TextField value.
                            });
                          } else {
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(initialDate);

                            setState(() {
                              zeAdmissaController.text = (widget.isEditing)
                                  ? DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(widget.sze010.ze_admissa))
                                  : formattedDate; //set foratted date to TextField value.
                            });
                          }
                        }),
                  ), // Admissao
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                        controller: zeFperaqController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: "Periodo Aquisitivo: ",
                        ),
                        readOnly: true,
                        onTap: () async {
                          pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.parse('1900-01-01'),
                            lastDate:
                                DateTime.now().add(const Duration(days: 90)),
                          );

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(pickedDate!);

                            setState(() {
                              zeFperaqController.text =
                                  formattedDate; //set foratted date to TextField value.
                            });
                          } else {
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(initialDate);

                            setState(() {
                              zeFperaqController.text = (widget.isEditing)
                                  ? DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(widget.sze010.ze_admissa))
                                  : formattedDate; //set foratted date to TextField value.
                            });
                          }
                        }),
                  ), // Periodo Aquisitivo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                        controller: zeNiverController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: "Nascimento: ",
                        ),
                        readOnly: true,
                        onTap: () async {
                          pickedDateNiver = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.parse('1900-01-01'),
                            lastDate:
                                DateTime.now().add(const Duration(days: 90)),
                          );

                          if (pickedDateNiver != null) {
                            String formattedDate = DateFormat('dd/MM/yyyy')
                                .format(pickedDateNiver!);

                            setState(() {
                              zeNiverController.text =
                                  formattedDate; //set foratted date to TextField value.
                            });
                          } else {
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(initialDate);

                            setState(() {
                              zeNiverController.text = (widget.isEditing)
                                  ? DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(widget.sze010.ze_niver))
                                  : formattedDate; //set foratted date to TextField value.
                            });
                          }
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 2.0),
                          child: Text(
                            'Departamento?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: DropdownButton<String>(
                            value: departamento,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14),
                            items: depto
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                departamento = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  (isRequestReady)
                  ? InkWell(
                    onTap: () {
                        (nameValidation)
                        ? ErrorDialog(
                            context,
                            'Existem erros que impedem o cadastro do Colaborador, '
                            'favor verificar!')
                        : registerCampaing(context);
                      },
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text('Criar',
                                    style: GoogleFonts.actor(
                                      textStyle: const TextStyle(fontSize: 20),
                                      color: Colors.black,
                                    ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.black.withAlpha(50)
                                ),
                                child: const Icon(
                                  Icons.chevron_right_rounded, 
                                  size: 30, 
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  )
                  : InkWell(
                            onTap: () {
                                ErrorDialog(
                                    context, "Aguarde o processamento.");
                              },
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Aguarde',
                                          style: GoogleFonts.actor(
                                            textStyle: const TextStyle(fontSize: 20),
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ),
                ],
              ),
            ),
      drawer: menuDrawer(context),
    );
  }

  Future<String> verifyId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //TODO: Criar uma classe de valores
    String? id = sharedPreferences.getString('accessToken');
    if (id != null) {
      return userId = id;
    }
    return userId;
  }

  registerCampaing(BuildContext context) async {
    Sze010Service sze010Service = Sze010Service();

    SharedPreferences.getInstance().then((prefs) {
      if (widget.isEditing) {
        String deptoConvert = '';

        database.forEach((key, value) {
          if (key == departamento) {
            deptoConvert = value.substring(0, 1);
          }
        });

        Sze010 internalSze010 = Sze010(
          ze_mat: widget.sze010.ze_mat,
          ze_nome: zeNomeController.text.toUpperCase(),
          ze_admissa: zeAdmissaController.text.substring(6, 10) +
              zeAdmissaController.text.substring(3, 5) +
              zeAdmissaController.text.substring(0, 2),
          ze_fperaq: zeFperaqController.text.substring(6, 10) +
              zeFperaqController.text.substring(3, 5) +
              zeFperaqController.text.substring(0, 2),
          ze_fervenc: (feriasVencidas.substring(0, 1) == 'S') ? '1' : '2',
          ze_dirferi: (direitoFerias.substring(0, 1) == 'S') ? '1' : '2',
          ze_feragen: (feriasAgendadas.substring(0, 1) == 'S') ? '1' : '2',
          ze_diasfer: double.parse(zeDiasferController.text),
          ze_saldfer: double.parse(zeSaldferController.text),
          ze_antefer: (antecipFerias.substring(0, 1) == 'S') ? '1' : '2',
          ze_ferpg: (feriasPagas.substring(0, 1) == 'S') ? '1' : '2',
          ze_depto: deptoConvert,
          ze_niver: zeNiverController.text.substring(6, 10) +
              zeNiverController.text.substring(3, 5) +
              zeNiverController.text.substring(0, 2),
          ze_conveni: zeConveniController.text.substring(6, 10) +
              zeConveniController.text.substring(3, 5) +
              zeConveniController.text.substring(0, 2),
          ze_email: widget.sze010.ze_email,
          r_e_c_n_o_field: widget.sze010.r_e_c_n_o_field,
        );

        sze010Service
            .edit(widget.sze010.r_e_c_n_o_field, internalSze010)
            .then((value) {
          if (value) {
            setState(() {
              isRequestReady = true;
            });
            Navigator.pop(context, DisposeStatus.success);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Sze010Screen(
                        isloading: true,
                      )),
            );
            return SuccessDialog(context, 'Colaborador Alterado com Sucesso!');
          } else {
            setState(() {
              isRequestReady = true;
            });
            Navigator.pop(context, DisposeStatus.error);
            return ErrorDialog(
                context, 'Erro na requisição, tente mais tarde!');
          }
        });
      } else {
        String deptoConvert = '';

        database.forEach((key, value) {
          if (key == departamento) {
            deptoConvert = value.substring(0, 1);
          }
        });

        Sze010 internalSze010 = Sze010(
          ze_mat: zeMatController.text,
          ze_nome: zeNomeController.text.toUpperCase(),
          ze_admissa: zeAdmissaController.text.substring(6, 10) +
              zeAdmissaController.text.substring(3, 5) +
              zeAdmissaController.text.substring(0, 2),
          ze_fperaq: zeFperaqController.text.substring(6, 10) +
              zeFperaqController.text.substring(3, 5) +
              zeFperaqController.text.substring(0, 2),
          ze_fervenc: '2',
          ze_dirferi: '2',
          ze_feragen: '2',
          ze_diasfer: 0.0,
          ze_saldfer: 30.0,
          ze_antefer: '2',
          ze_ferpg: '2',
          ze_depto: deptoConvert,
          ze_niver: '2000${zeNiverController.text.substring(3, 5)}'
              '${zeNiverController.text.substring(0, 2)}',
          ze_conveni: '00000000',
          ze_email: '',
          r_e_c_n_o_field: 0,
        );

        sze010Service.register(internalSze010).then((value) {
          if (value) {
            setState(() {
              isRequestReady = true;
            });
            Navigator.pop(context, DisposeStatus.success);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Sze010Screen(
                        isloading: true,
                      )),
            );
            return SuccessDialog(
                context, 'Colaborador Cadastrado com Sucesso!');
          } else {
            Navigator.pop(context, DisposeStatus.error);
            return ErrorDialog(
                context, 'Erro na requisição, tente mais tarde!');
          }
        });
      }
    });
  }

  void getSqb010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      String dptoSze = '';

      if (firstName != null && lastName != null) {
        _sqb010service.getAll().then((List<Sqb010> listSqb010) {
          setState(() {
            for (Sqb010 sqb010 in listSqb010) {
              depto.add(sqb010.qb_descric);
              database[sqb010.qb_descric] = sqb010.qb_depto;
              if (widget.sze010.ze_depto == sqb010.qb_depto.substring(0, 1)) {
                dptoSze = sqb010.qb_descric;
              }
            }

            (widget.isEditing)
                ? departamento = dptoSze
                : departamento = depto.first;
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}

enum DisposeStatus { exit, error, success }
