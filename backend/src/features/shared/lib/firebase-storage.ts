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

export async function deletePostImage(imagePath: string): Promise<void> {
  const bucket = getStorage().bucket();
  const file = bucket.file(imagePath);
  try {
    await file.delete();
  } catch (err: unknown) {
    // If the file doesn't exist, we can ignore the error for cleanup purposes
    if (err && typeof err === 'object' && 'code' in err && err.code !== 404) {
      throw err;
    }
  }
}
