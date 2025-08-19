import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/reviews_provider.dart';
import '../../providers/auth_provider.dart';

class PartReviewsSection extends StatelessWidget {
  final String partId;
  const PartReviewsSection({super.key, required this.partId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentComposer(partId: partId),
        const SizedBox(height: 8),
        _CommentsList(partId: partId),
      ],
    );
  }
}

class SafeTextController extends TextEditingController {
  void setTextSafely(String text) {
    value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }

  void clearSafely() => setTextSafely('');
}

class _CommentComposer extends StatefulWidget {
  final String partId;
  const _CommentComposer({required this.partId});

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _ctrl = SafeTextController();

  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    final content = _ctrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب تعليقاً أولاً')),
      );
      return;
    }
    final uid = context.read<AuthProvider>().userId ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل الدخول أولاً')),
      );
      return;
    }
    setState(() => _sending = true);
    final ok = await context.read<ReviewsProvider>().addComment(
      partId: widget.partId,
      userId: uid,
      content: content,
    );
    setState(() => _sending = false);
    if (ok) {
      _ctrl.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ تعليقك ✅')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل حفظ التعليق ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أضف تعليقك:'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: CupertinoTextField(
                controller: _ctrl,
                maxLines: 2,
                padding: const EdgeInsets.all(12),
                placeholder: 'اكتب تعليقًا ...',
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                clearButtonMode: OverlayVisibilityMode.never,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: const Icon(Icons.send),
              label: Text(_sending ? 'جارٍ الإرسال...' : 'إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsList extends StatefulWidget {
  final String partId;
  const _CommentsList({required this.partId});

  @override
  State<_CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<_CommentsList> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_fetched) {
        context.read<ReviewsProvider>().fetchPartComments(widget.partId);
        _fetched = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsProvider>(
      builder: (_, p, __) {
        if (p.isLoading && p.comments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (p.comments.isEmpty) {
          return const Text('لا توجد تعليقات بعد.');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: p.comments.length,
          separatorBuilder: (_, __) => const Divider(height: 8),
          itemBuilder: (_, i) {
            final c = p.comments[i];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                c.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.content),
                  Text(
                    '${c.createdAt}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
