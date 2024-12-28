import 'package:fedi_pipe/repositories/persistent/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManageAccountsPage extends StatelessWidget {
  const ManageAccountsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final availableAccounts = authRepository.availableAccounts();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder(
                future: availableAccounts,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final accounts = snapshot.data;
                    print(accounts);
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: accounts!.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return ListTile(
                          title: Text(account.instance),
                          onTap: () {
                            authRepository.setActiveAuth(account.id!);
                            Navigator.of(context).pop();
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              authRepository.deleteAuth(account.id!);
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
            ElevatedButton(
              onPressed: () {
                context.pushNamed('add-token');
              },
              child: const Text('Add Account'),
            ),
          ],
        ),
      ),
    );
  }
}
