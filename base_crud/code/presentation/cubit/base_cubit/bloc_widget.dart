import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'async_cubit.dart';

abstract class BlocStatelessWidget<C extends AsyncCubit>
    extends StatelessWidget {
  const BlocStatelessWidget({super.key});

  C get create;

  Widget buildContent(BuildContext context, C ref);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AsyncCubit>(
      create: (context) => create,
      child: Builder(builder: (context) {
        final cubit = BlocProvider.of<C>(context);
        return buildContent(context, cubit);
      }),
    );
  }
}

abstract class BlocStatefulWidget<C extends AsyncCubit> extends StatefulWidget {
  const BlocStatefulWidget({super.key});

  C get create;

  void initState() {}

  void dispose() {}

  Widget buildContent(BuildContext context, C ref, State state);

  @override
  State<BlocStatefulWidget<C>> createState() => _BlocStatefulWidgetState<C>();
}

class _BlocStatefulWidgetState<C extends AsyncCubit>
    extends State<BlocStatefulWidget<C>> {
  @override
  void initState() {
    widget.initState();
    super.initState();
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AsyncCubit>(
      create: (context) => widget.create,
      child: Builder(builder: (context) {
        final cubit = BlocProvider.of<C>(context);
        return widget.buildContent(context, cubit, this);
      }),
    );
  }
}
