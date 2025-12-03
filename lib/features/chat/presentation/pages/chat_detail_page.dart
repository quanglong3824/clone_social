import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/chat/domain/entities/chat_entity.dart';
import 'package:clone_social/features/chat/domain/entities/message_entity.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String? otherUserName;
  final String? otherUserImage;
  final String? otherUserId;

  const ChatDetailPage({
    super.key, 
    required this.chatId,
    this.otherUserName,
    this.otherUserImage,
    this.otherUserId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  
  bool _isSending = false;
  Timer? _typingTimer;
  String? _otherUserId;
  String _otherUserName = '';
  String? _otherUserImage;
  bool _isSearching = false;
  final _searchController = TextEditingController();
  List<MessageEntity> _searchResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _messageController.addListener(_onTextChanged);
    
    // Initialize with passed values if available
    if (widget.otherUserName != null) {
      _otherUserName = widget.otherUserName!;
    }
    if (widget.otherUserImage != null) {
      _otherUserImage = widget.otherUserImage;
    }
    if (widget.otherUserId != null) {
      _otherUserId = widget.otherUserId;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsRead();
      _loadChatInfo();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _setTyping(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _setTyping(false);
    }
  }

  Future<void> _loadChatInfo() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final chat = await context.read<ChatProvider>().getChatById(widget.chatId, currentUser.id);
    if (chat != null && chat.participants.isNotEmpty && mounted) {
      final otherUserId = chat.participants.firstWhere(
        (id) => id != currentUser.id,
        orElse: () => '',
      );
      
      if (otherUserId.isNotEmpty) {
        final otherUserInfo = chat.participantInfo[otherUserId] ?? {};
        setState(() {
          _otherUserId = otherUserId;
          _otherUserName = otherUserInfo['name'] ?? 'Unknown';
          _otherUserImage = otherUserInfo['profileImage'];
        });
      }
    }
  }

  void _markAsRead() {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      context.read<ChatProvider>().markAllAsRead(widget.chatId, currentUser.id);
    }
  }

  void _onTextChanged() {
    _setTyping(_messageController.text.isNotEmpty);
    setState(() {}); // Update send button state
  }

  void _setTyping(bool isTyping) {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    _typingTimer?.cancel();
    context.read<ChatProvider>().setTyping(widget.chatId, currentUser.id, isTyping);

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          context.read<ChatProvider>().setTyping(widget.chatId, currentUser.id, false);
        }
      });
    }
  }


  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    // Clear input immediately for better UX
    _messageController.clear();
    _setTyping(false);
    
    setState(() => _isSending = true);

    try {
      await context.read<ChatProvider>().sendMessage(
        widget.chatId,
        currentUser.id,
        text,
      );

      if (mounted) {
        setState(() => _isSending = false);
        
        // Scroll to bottom
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi tin nhắn thất bại: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép tin nhắn')),
    );
  }

  Future<void> _deleteMessage(MessageEntity message) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tin nhắn'),
        content: const Text('Bạn có chắc muốn xóa tin nhắn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<ChatProvider>().deleteMessage(
        widget.chatId,
        message.id,
        currentUser.id,
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa tin nhắn thất bại'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showMessageOptions(MessageEntity message, bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.text.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Sao chép'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessage(message.text);
                },
              ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchMessages(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final results = await context.read<ChatProvider>().searchMessages(widget.chatId, query);
    if (mounted) {
      setState(() => _searchResults = results);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }

    return Scaffold(
      appBar: _buildAppBar(currentUser.id),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(currentUser.id)),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String currentUserId) {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _toggleSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm tin nhắn...',
            border: InputBorder.none,
          ),
          onChanged: _searchMessages,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _searchMessages('');
              },
            ),
        ],
      );
    }

    return AppBar(
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () {
          if (_otherUserId != null && _otherUserId!.isNotEmpty) {
            context.push('/profile/$_otherUserId');
          }
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage: _otherUserImage != null && _otherUserImage!.isNotEmpty
                  ? NetworkImage(_otherUserImage!)
                  : null,
              child: _otherUserImage == null || _otherUserImage!.isEmpty
                  ? const Icon(Icons.person, size: 20, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUserName.isEmpty ? 'Đang tải...' : _otherUserName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  _buildTypingIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return StreamBuilder<Map<String, bool>>(
      stream: context.read<ChatProvider>().getTypingStatus(widget.chatId),
      builder: (context, snapshot) {
        if (snapshot.hasData && _otherUserId != null) {
          final isTyping = snapshot.data?[_otherUserId] ?? false;
          if (isTyping) {
            return const Text(
              'Đang nhập...',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.primaryBlue,
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }


  Widget _buildMessageList(String currentUserId) {
    return StreamBuilder<List<MessageEntity>>(
      stream: context.read<ChatProvider>().getMessages(widget.chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final messages = _isSearching && _searchResults.isNotEmpty
            ? _searchResults
            : (snapshot.data ?? []);

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có tin nhắn',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy gửi tin nhắn để bắt đầu cuộc trò chuyện',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == currentUserId;
            
            // Check if we should show date separator
            final showDateSeparator = _shouldShowDateSeparator(messages, index);
            
            return Column(
              children: [
                if (showDateSeparator)
                  _buildDateSeparator(message.createdAt),
                GestureDetector(
                  onLongPress: () => _showMessageOptions(message, isMe),
                  child: _buildMessageBubble(message, isMe),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _shouldShowDateSeparator(List<MessageEntity> messages, int index) {
    if (index == messages.length - 1) return true;
    
    final currentDate = messages[index].createdAt;
    final previousDate = messages[index + 1].createdAt;
    
    return currentDate.day != previousDate.day ||
           currentDate.month != previousDate.month ||
           currentDate.year != previousDate.year;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String dateText;
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      dateText = 'Hôm nay';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      dateText = 'Hôm qua';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity message, bool isMe) {
    final hasImage = message.mediaUrl != null && message.mediaUrl!.isNotEmpty;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildMessageImage(message.mediaUrl!),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primaryBlue : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.read ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.read ? AppTheme.primaryBlue : Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year && time.month == now.month && time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return timeago.format(time, locale: 'vi');
  }

  Widget _buildMessageImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        return GestureDetector(
          onTap: () => _showFullImage(imageUrl),
          child: Image.memory(
            base64Decode(base64Data),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImageError(),
          ),
        );
      } catch (e) {
        return _buildImageError();
      }
    }
    return GestureDetector(
      onTap: () => _showFullImage(imageUrl),
      child: Image.network(
        imageUrl,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageError(),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: imageUrl.startsWith('data:image')
                  ? Image.memory(
                      base64Decode(imageUrl.split(',').last),
                      fit: BoxFit.contain,
                    )
                  : Image.network(imageUrl, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Image picker button
            IconButton(
              icon: Icon(Icons.image, color: AppTheme.primaryBlue),
              onPressed: _pickAndSendImage,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  void _pickAndSendImage() {
    // Image picker removed - not supported on Flutter Web
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng gửi ảnh sẽ sớm có')),
    );
  }

  Widget _buildSendButton() {
    final hasText = _messageController.text.trim().isNotEmpty;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      child: Material(
        color: hasText ? AppTheme.primaryBlue : Colors.grey[300],
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _isSending || !hasText ? null : _sendMessage,
          child: Center(
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: hasText ? Colors.white : Colors.grey[500],
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }

  void _showChatOptions() {
    final currentUser = context.read<AuthProvider>().currentUser;
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Xem trang cá nhân'),
              onTap: () {
                Navigator.pop(ctx);
                if (_otherUserId != null && _otherUserId!.isNotEmpty) {
                  context.push('/profile/$_otherUserId');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Tìm kiếm trong cuộc trò chuyện'),
              onTap: () {
                Navigator.pop(ctx);
                _toggleSearch();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa cuộc trò chuyện', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa cuộc trò chuyện'),
                    content: const Text('Bạn có chắc muốn xóa cuộc trò chuyện này? Hành động này không thể hoàn tác.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && currentUser != null && mounted) {
                  final success = await context.read<ChatProvider>().deleteChat(
                    widget.chatId,
                    currentUser.id,
                  );
                  if (success && mounted) {
                    context.pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
