import { getStorage } from "firebase-admin/storage";
import { randomUUID } from "crypto";

export async function uploadPostImage(buffer: Buffer, mimeType: string): Promise<{ imageUrl: string; imagePath: string }> {
  const bucket = getStorage().bucket();
  const id = randomUUID();
  const extension = mimeType.split('/')[1] || 'jpg';
  const imagePath = `posts/${id}.${extension}`;
  const file = bucket.file(imagePath);

  await file.save(buffer, {
    metadata: {
      contentType: mimeType,
    },
  });
  
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: '03-01-2500', // Far in the future
  });

  return { imageUrl: url, imagePath };
}
