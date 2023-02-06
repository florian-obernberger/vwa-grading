import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwa_grading/data/toast_messages.dart';
import 'package:vwa_grading/destinations/section.dart';
import 'package:vwa_grading/destinations/written_end.dart';
import 'package:vwa_grading/pdf/vwa_beurteilungsraster.dart';
import 'package:vwa_grading/state-management/preferences.dart';
import 'package:vwa_grading/destinations/destinations_mixin.dart';
import 'package:vwa_grading/destinations/general_info.dart';
import 'package:vwa_grading/m3/drawer/drawer.dart';
import 'package:vwa_grading/state-management/vwa_data.dart';

import 'package:vwa_grading/data/export/export_stub.dart'
    if (dart.library.io) 'package:vwa_grading/data/export/export.dart'
    if (dart.library.html) 'package:vwa_grading/data/export/export_web.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class PageSlider extends StatefulWidget {
  const PageSlider({super.key});

  @override
  State<PageSlider> createState() => _PageSliderState();
}

class _PageSliderState extends State<PageSlider> {
  late List<PageSliderDestinationMixin> _pages;
  late final List<StandardDrawerItem> _drawerItems;
  late final List<PopupMenuItem<VWAExportType>> _exportItems;
  int _selectedIndex = 0;

  final _extended = true;

  @override
  void initState() {
    super.initState();
    _updatePages();

    _drawerItems = [
      for (PageSliderDestinationMixin p in _pages)
        StandardDrawerItem(
          label: p.label,
          icon: Icon(p.icon),
          selectedIcon: Icon(p.selectedIcon),
        ),
    ];

    _exportItems = [
      PopupMenuItem(
        value: VWAExportType.pdfWritten,
        child: Text("${questionsProvider.written.name} (PDF)"),
      ),
      PopupMenuItem(
        value: VWAExportType.pdfSpoken,
        child: Text(
          "${questionsProvider.presentation.name} & ${questionsProvider.discussion.name} (PDF)",
        ),
      ),
      const PopupMenuItem(
        value: VWAExportType.pdfTotal,
        child: Text("Gesamt (PDF)"),
      ),
      const PopupMenuItem(
        value: VWAExportType.toml,
        child: Text("Zwischenspeichern (VWA)"),
      ),
    ];
  }

  void _updatePages() {
    _pages = [
      GeneralInfo(key: UniqueKey()),
      for (var wSection in questionsProvider.written.sections)
        QuestionsSection(
          key: UniqueKey(),
          groupName: questionsProvider.written.name,
          section: wSection,
        ),
      const EndWrittenPart(),
      for (var qSection in questionsProvider.presentation.sections)
        QuestionsSection(
          key: UniqueKey(),
          groupName: questionsProvider.presentation.name,
          section: qSection,
        ),
      for (var dSection in questionsProvider.discussion.sections)
        QuestionsSection(
          key: UniqueKey(),
          groupName: questionsProvider.discussion.name,
          section: dSection,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final drawerCollapsed = constraints.maxWidth <= 1200;
          final isMobile = constraints.maxWidth <= 900;

          final widthFactor = drawerCollapsed ? 1.0 : 0.8;

          return Row(
            children: [
              if (!drawerCollapsed) _buildDrawer(drawerCollapsed),
              Expanded(
                child: Scaffold(
                  key: _scaffoldKey,
                  appBar: _buildTopAppBar(isMobile),
                  drawer:
                      drawerCollapsed ? _buildDrawer(drawerCollapsed) : null,
                  bottomNavigationBar: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: _buildNavigationButtons(isMobile),
                  ),
                  body: SizedBox.expand(
                    child: FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: FocusTraversalGroup(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: _pages[_selectedIndex],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawer(bool isMobile) {
    return StandardDrawer(
      modal: isMobile,
      leading: _buildLogo(),
      items: _drawerItems,
      selectedIndex: _selectedIndex,
      onSelectionChanged: (value) {
        if (isMobile) _toggleDrawer();
        setState(
          () => _selectedIndex = value,
        );
      },
    );
  }

  AppBar _buildTopAppBar(bool isMobile) {
    final isLightMode = themeModePrefNotifier.value == 1;

    return AppBar(
      scrolledUnderElevation: isMobile ? 2 : 0,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.only(left: 16, right: 16),
          ),
          onPressed: () async {
            final res = await importToml();

            switch (res.status) {
              case ImportStatus.cancelled:
                break;
              case ImportStatus.openError:
                _showToast(ToastMessages.couldntOpenFile(res.fileName));
                break;
              case ImportStatus.parseError:
                _showToast(ToastMessages.couldntLoadFile(res.fileName));
                break;
              case ImportStatus.readError:
                _showToast(ToastMessages.couldntReadFile(res.fileName));
                break;
              case ImportStatus.noIssues:
                setState(_updatePages);
                _showToast(ToastMessages.importedFile(res.fileName));
                break;
            }
          },
          child: const Text("Importieren"),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final chosen = await showMenu<VWAExportType>(
              context: context,
              // No idea how that works but it does!
              position: RelativeRect.fromDirectional(
                textDirection: TextDirection.rtl,
                start: 0,
                top: 0,
                end: 1,
                bottom: 0,
              ),
              items: _exportItems,
            );

            if (chosen == null) {
              return;
            } else if (chosen == VWAExportType.toml) {
              exportToml().then(
                (_) => _showToast(ToastMessages.savedChanges),
              );
            } else {
              // ignore: use_build_context_synchronously
              final withKalkul = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text("PDF Export"),
                  content: const Text("Soll das Kalkül berechnet werden?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Ja"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Nein"),
                    ),
                  ],
                ),
              );

              if (withKalkul == null) return;

              exportPdf(chosen, withKalkul).then(
                (_) => _showToast(ToastMessages.exportedPdf),
              );
            }
          },
          icon: const Text("Exportieren"),
          label: const Icon(Icons.arrow_drop_down),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.only(left: 24, right: 16),
          ),
        ),
        IconButton(
          onPressed: () => themeModePrefNotifier.value = isLightMode ? -1 : 1,
          icon: Icon(isLightMode ? Icons.dark_mode : Icons.light_mode),
        ),
      ]
          .map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4), child: e))
          .toList(),
    );
  }

  Widget _buildLogo() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final isLightMode = themeModePrefNotifier.value == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          isLightMode ? "assets/logo.svg" : "assets/logo-dark.svg",
          width: _extended ? 128 : 64,
          height: _extended ? 128 : 64,
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Text(
            "VWA Benotung",
            style: (_extended ? textTheme.titleLarge : textTheme.titleSmall)
                ?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isCollapsed) {
    final isFirst = _selectedIndex == 0;
    final isLast = _selectedIndex == _pages.length - 1;

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buttonWrapper({required Widget child}) =>
        isCollapsed ? Flexible(child: child) : Expanded(child: child);

    final spacer =
        isCollapsed ? const SizedBox(height: 16) : const SizedBox(width: 16);

    final buttonTextStyle =
        (isCollapsed ? textTheme.titleMedium : textTheme.headlineSmall)
            ?.copyWith(color: colorScheme.onSecondaryContainer);

    final buttons = [
      if (!isFirst)
        buttonWrapper(
          child: _buildCustomButton(
            isCollapsed,
            onPressed: () => setState(() => _selectedIndex--),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    RotatedBox(
                      quarterTurns: 2,
                      child: Icon(Icons.arrow_right_alt),
                    ),
                    Text("Zurück"),
                  ],
                ),
                Text(
                  _pages[_selectedIndex - 1].label,
                  style: buttonTextStyle,
                ),
              ],
            ),
          ),
        ),
      if (isFirst) spacer,
      if (!isCollapsed && (isFirst ^ isLast)) const Spacer(),
      if (!isFirst) spacer,
      if (!isLast)
        buttonWrapper(
          child: _buildCustomButton(
            isCollapsed,
            onPressed: () => setState(() => _selectedIndex++),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_right_alt),
                    Text("Weiter"),
                  ],
                ),
                Text(
                  _pages[_selectedIndex + 1].label,
                  style: buttonTextStyle,
                ),
              ],
            ),
          ),
        ),
    ];

    return Padding(
      padding:
          isCollapsed ? const EdgeInsets.all(16) : const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCollapsed)
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons,
            ),
          if (isCollapsed) ...buttons,
        ],
      ),
    );
  }

  Widget _buildCustomButton(bool isCollapsed,
      {Widget? child, VoidCallback? onPressed}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      style: FilledButton.styleFrom(elevation: 0).copyWith(
        shape: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            );
          } else if (states.contains(MaterialState.focused)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
              side: BorderSide(color: colorScheme.outline, width: 2),
            );
          } else {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            );
          }
        }),
        overlayColor: const MaterialStatePropertyAll(Colors.transparent),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed) ||
              states.contains(MaterialState.focused)) {
            return colorScheme.secondaryContainer;
          } else {
            return ElevationOverlay.applySurfaceTint(
              colorScheme.surface,
              colorScheme.surfaceTint,
              1,
            );
          }
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed) ||
              states.contains(MaterialState.focused)) {
            return colorScheme.onSecondaryContainer;
          } else {
            return colorScheme.onSurfaceVariant;
          }
        }),
        textStyle: MaterialStatePropertyAll(
            isCollapsed ? textTheme.titleSmall : textTheme.titleMedium),
        alignment: Alignment.centerLeft,
      ),
      onPressed: onPressed,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  void _toggleDrawer() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  void _showToast(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 18),
        content: Text(content),
      ),
    );
  }
}
